/**
 * Community Membership Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { getAll, getById, create, update, remove, queryByChild, db } = require('../config/firebase');

const MEMBERSHIPS_REF = 'communityMemberships';
const COMMUNITIES_REF = 'communities';
const USERS_REF = 'users';

class CommunityMembershipService {
    /**
     * Get all memberships (admin)
     */
    async findAll() {
        const memberships = await getAll(MEMBERSHIPS_REF);
        // Enrich with community and user data
        return Promise.all(memberships.map(async (mem) => {
            const community = await getById(COMMUNITIES_REF, mem.communityId);
            const user = await getById(USERS_REF, mem.userId);
            return {
                ...mem,
                communityName: community?.name || null,
                communityCategory: community?.category || null,
                userName: user?.name || null,
                userEmail: user?.email || null,
            };
        }));
    }

    /**
     * Get members by community
     */
    async findByCommunity(communityId) {
        const memberships = await queryByChild(MEMBERSHIPS_REF, 'communityId', communityId);
        return Promise.all(memberships.map(async (mem) => {
            const user = await getById(USERS_REF, mem.userId);
            return {
                ...mem,
                userName: user?.name || null,
                userEmail: user?.email || null,
            };
        }));
    }

    /**
     * Get communities by user
     */
    async findByUser(userId) {
        const memberships = await queryByChild(MEMBERSHIPS_REF, 'userId', userId);
        return Promise.all(memberships.map(async (mem) => {
            const community = await getById(COMMUNITIES_REF, mem.communityId);
            return {
                ...mem,
                communityName: community?.name || null,
                communityCategory: community?.category || null,
                communityDescription: community?.description || null,
                communityImageUrl: community?.imageUrl || null,
            };
        }));
    }

    /**
     * Check if user is member of community
     */
    async isMember(communityId, userId) {
        const memberships = await queryByChild(MEMBERSHIPS_REF, 'communityId', communityId);
        return memberships.some(mem => mem.userId === userId && mem.status === 'active');
    }

    /**
     * Join community
     */
    async join(communityId, userId) {
        // Check if already member
        const isAlreadyMember = await this.isMember(communityId, userId);
        if (isAlreadyMember) {
            throw new Error('Anda sudah menjadi anggota komunitas ini');
        }

        const id = uuidv4();
        const now = new Date().toISOString();

        const membershipData = {
            communityId,
            userId,
            status: 'active', // active, left
            role: 'member', // member, admin
            joinedAt: now,
            updatedAt: now,
        };

        await create(MEMBERSHIPS_REF, id, membershipData);

        // Update member count in community
        const community = await getById(COMMUNITIES_REF, communityId);
        if (community) {
            const newCount = (community.memberCount || 0) + 1;
            await update(COMMUNITIES_REF, communityId, { memberCount: newCount });
        }

        return { id, ...membershipData };
    }

    /**
     * Leave community
     */
    async leave(id, userId) {
        const membership = await getById(MEMBERSHIPS_REF, id);
        if (!membership) {
            throw new Error('Keanggotaan tidak ditemukan');
        }
        if (membership.userId !== userId) {
            throw new Error('Tidak memiliki akses untuk keluar dari komunitas ini');
        }

        await update(MEMBERSHIPS_REF, id, {
            status: 'left',
            updatedAt: new Date().toISOString()
        });

        // Update member count in community
        const community = await getById(COMMUNITIES_REF, membership.communityId);
        if (community && community.memberCount > 0) {
            const newCount = community.memberCount - 1;
            await update(COMMUNITIES_REF, membership.communityId, { memberCount: newCount });
        }

        return { success: true };
    }

    /**
     * Update membership (admin)
     */
    async updateRole(id, role) {
        await update(MEMBERSHIPS_REF, id, {
            role,
            updatedAt: new Date().toISOString(),
        });
        return getById(MEMBERSHIPS_REF, id);
    }

    /**
     * Delete membership (admin)
     */
    async delete(id) {
        const membership = await getById(MEMBERSHIPS_REF, id);
        if (membership) {
            // Update member count
            const community = await getById(COMMUNITIES_REF, membership.communityId);
            if (community && community.memberCount > 0) {
                const newCount = community.memberCount - 1;
                await update(COMMUNITIES_REF, membership.communityId, { memberCount: newCount });
            }
        }

        await remove(MEMBERSHIPS_REF, id);
        return { deleted: true };
    }

    /**
     * Get member count for community
     */
    async getCountByCommunity(communityId) {
        const memberships = await queryByChild(MEMBERSHIPS_REF, 'communityId', communityId);
        return memberships.filter(m => m.status === 'active').length;
    }
}

module.exports = new CommunityMembershipService();
