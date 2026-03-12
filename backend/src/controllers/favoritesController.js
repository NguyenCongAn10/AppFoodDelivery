import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// Get user's favorite items
export const getFavorites = async (req, res) => {
  try {
    const user_uid = req.user.uid;
    const items = await prisma.favorites.findMany({
      where: { user_uid },
      include: {
        foods: {
          include: {
            restaurants: true
          }
        }
      },
      orderBy: { created_at: 'desc' }
    });

    res.status(200).json(items);
  } catch (error) {
    console.error('Lỗi khi lấy danh sách yêu thích:', error);
    res.status(500).json({ error: 'Lỗi server khi lấy danh sách yêu thích' });
  }
};

// Toggle item in favorites
export const toggleFavorite = async (req, res) => {
  try {
    const user_uid = req.user.uid;
    const { food_id } = req.body;

    if (!food_id) {
      return res.status(400).json({ error: 'Thiếu thông tin món ăn' });
    }

    // Check if food exists
    const food = await prisma.foods.findUnique({
      where: { id: parseInt(food_id) },
      select: { id: true, restaurant_id: true } // Include restaurant_id
    });

    if (!food) {
      return res.status(404).json({ error: 'Không tìm thấy món ăn' });
    }

    const existingFavorite = await prisma.favorites.findUnique({
      where: {
        user_uid_food_id: {
          user_uid,
          food_id: parseInt(food_id)
        }
      }
    });

    if (existingFavorite) {
      // If it exists, remove it
      await prisma.favorites.delete({
        where: { id: existingFavorite.id }
      });
      return res.status(200).json({ message: 'Đã bỏ yêu thích', isFavorite: false });
    } else {
      // If it doesn't exist, add it
      const newFav = await prisma.favorites.create({
        data: {
          user_uid,
          food_id: parseInt(food_id),
          restaurant_id: food.restaurant_id
        }
      });
      return res.status(200).json({ message: 'Đã thêm vào yêu thích', isFavorite: true, favorite: newFav });
    }
  } catch (error) {
    console.error('Lỗi khi toggle yêu thích:', error);
    res.status(500).json({ error: 'Lỗi server khi cập nhật yêu thích' });
  }
};
