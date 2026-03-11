import prisma from '../config/prisma.js';

export const getAddresses = async (req, res) => {
    try {
        const userUid = req.user.uid;
        const addresses = await prisma.addresses.findMany({
            where: { user_uid: userUid },
            orderBy: { created_at: 'desc' }
        });
        res.status(200).json(addresses);
    } catch (err) {
        console.error("Get addresses error:", err);
        res.status(500).json({ error: err.message || "Unknown error" });
    }
};

export const addAddress = async (req, res) => {
    try {
        const userUid = req.user.uid;
        const { address, latitude, longitude, is_default } = req.body;

        // Check if user has any address. If not, make this the default.
        const addressCount = await prisma.addresses.count({
            where: { user_uid: userUid }
        });

        const shouldBeDefault = addressCount === 0 || is_default === true;

        if (shouldBeDefault) {
            // Unset other defaults if this one is going to be default
            await prisma.addresses.updateMany({
                where: { user_uid: userUid, is_default: true },
                data: { is_default: false }
            });
        }

        const newAddress = await prisma.addresses.create({
            data: {
                user_uid: userUid,
                address,
                latitude,
                longitude,
                is_default: shouldBeDefault
            }
        });

        res.status(201).json(newAddress);
    } catch (err) {
        console.error("Add address error:", err);
        res.status(500).json({ error: err.message || "Unknown error" });
    }
};

export const updateAddress = async (req, res) => {
    try {
        const userUid = req.user.uid;
        const { id } = req.params;
        const { address, latitude, longitude, is_default } = req.body;

        // If setting as default, unset others first
        if (is_default === true) {
            await prisma.addresses.updateMany({
                where: { user_uid: userUid, is_default: true },
                data: { is_default: false }
            });
        }

        const updatedAddress = await prisma.addresses.update({
            where: { id: parseInt(id) },
            data: {
                ...(address !== undefined && { address }),
                ...(latitude !== undefined && { latitude }),
                ...(longitude !== undefined && { longitude }),
                ...(is_default !== undefined && { is_default }),
            }
        });

        res.status(200).json(updatedAddress);
    } catch (err) {
        console.error("Update address error:", err);
        res.status(500).json({ error: err.message || "Unknown error" });
    }
};

export const deleteAddress = async (req, res) => {
    try {
        const userUid = req.user.uid;
        const { id } = req.params;

        const addressToDelete = await prisma.addresses.findUnique({
            where: { id: parseInt(id) }
        });

        if (!addressToDelete || addressToDelete.user_uid !== userUid) {
            return res.status(404).json({ error: "Address not found" });
        }

        await prisma.addresses.delete({
            where: { id: parseInt(id) }
        });

        // If the deleted address was default, set the most recent one as default
        if (addressToDelete.is_default) {
            const latestAddress = await prisma.addresses.findFirst({
                where: { user_uid: userUid },
                orderBy: { created_at: 'desc' }
            });

            if (latestAddress) {
                await prisma.addresses.update({
                    where: { id: latestAddress.id },
                    data: { is_default: true }
                });
            }
        }

        res.status(200).json({ message: "Address deleted successfully" });
    } catch (err) {
        console.error("Delete address error:", err);
        res.status(500).json({ error: err.message || "Unknown error" });
    }
};
