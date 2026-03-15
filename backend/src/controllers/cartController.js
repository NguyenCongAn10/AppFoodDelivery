import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// Get user's cart
export const getCart = async (req, res) => {
  try {
    const user_uid = req.user.uid;
    const items = await prisma.cart_items.findMany({
      where: { user_uid },
      include: {
        foods: {
          include: {
            restaurants: true
          }
        }
      },
      orderBy: { created_at: 'asc' }
    });

    res.status(200).json(items);
  } catch (error) {
    console.error('Lỗi khi lấy giỏ hàng:', error);
    res.status(500).json({ error: 'Lỗi server khi lấy giỏ hàng' });
  }
};

// Add item to cart
export const addToCart = async (req, res) => {
  try {
    const user_uid = req.user.uid;
    const { food_id, quantity, selected_options } = req.body;

    if (!food_id) {
      return res.status(400).json({ error: 'Thiếu thông tin món ăn' });
    }

    const qty = quantity ? parseInt(quantity) : 1;

    // Check if food exists
    const food = await prisma.foods.findUnique({
      where: { id: parseInt(food_id) },
      include: { restaurants: true }
    });

    if (!food) {
      return res.status(404).json({ error: 'Không tìm thấy món ăn' });
    }

    // Check existing cart items
    const existingItems = await prisma.cart_items.findMany({
      where: { user_uid },
      include: { foods: true }
    });

    if (existingItems.length > 0) {
      const existingRestaurantId = existingItems[0].foods.restaurant_id;
      if (existingRestaurantId !== food.restaurant_id) {
        return res.status(400).json({ 
          error: 'Giỏ hàng chỉ có thể chứa món từ 1 nhà hàng. Hãy xoá giỏ hàng hiện tại trước.',
          code: 'DIFFERENT_RESTAURANT'
        });
      }
    }

    // Manual merge logic: compare options
    let existingItem = null;
    const newOpts = selected_options || [];
    
    existingItem = existingItems.find(item => {
        if (item.food_id !== parseInt(food_id)) return false;
        
        const itemOpts = item.selected_options || [];
        if (itemOpts.length !== newOpts.length) return false;
        
        const itemOptIds = itemOpts.map(o => o.id).sort().join(',');
        const newOptIds = newOpts.map(o => o.id).sort().join(',');
        return itemOptIds === newOptIds;
    });

    let item;
    if (existingItem) {
      item = await prisma.cart_items.update({
        where: { id: existingItem.id },
        data: { quantity: { increment: qty } },
        include: { foods: { include: { restaurants: true } } }
      });
    } else {
      item = await prisma.cart_items.create({
        data: {
          user_uid,
          food_id: parseInt(food_id),
          restaurant_id: food.restaurant_id,
          quantity: qty,
          selected_options: newOpts
        },
        include: { foods: { include: { restaurants: true } } }
      });
    }

    res.status(200).json(item);
  } catch (error) {
    console.error('Lỗi khi thêm vào giỏ hàng:', error);
    res.status(500).json({ error: 'Lỗi server khi thêm vào giỏ' });
  }
};

// Update cart item quantity
export const updateCartItem = async (req, res) => {
  try {
    const user_uid = req.user.uid;
    const cartItemId = parseInt(req.params.id);
    const { quantity } = req.body;

    if (!quantity || quantity < 1) {
      return res.status(400).json({ error: 'Số lượng không hợp lệ' });
    }

    // Verify ownership
    const existing = await prisma.cart_items.findUnique({
      where: { id: cartItemId }
    });

    if (!existing || existing.user_uid !== user_uid) {
      return res.status(404).json({ error: 'Không tìm thấy mục trong giỏ' });
    }

    const updated = await prisma.cart_items.update({
      where: { id: cartItemId },
      data: { quantity: parseInt(quantity) },
      include: {
        foods: { include: { restaurants: true } }
      }
    });

    res.status(200).json(updated);
  } catch (error) {
    console.error('Lỗi cập nhật giỏ hàng:', error);
    res.status(500).json({ error: 'Lỗi server khi cập nhật' });
  }
};

// Remove item from cart
export const removeFromCart = async (req, res) => {
  try {
    const user_uid = req.user.uid;
    const cartItemId = parseInt(req.params.id);

    const existing = await prisma.cart_items.findUnique({
      where: { id: cartItemId }
    });

    if (!existing || existing.user_uid !== user_uid) {
      return res.status(404).json({ error: 'Không tìm thấy mục trong giỏ' });
    }

    await prisma.cart_items.delete({
      where: { id: cartItemId }
    });

    res.status(200).json({ message: 'Xoá thành công' });
  } catch (error) {
    console.error('Lỗi xoá mục giỏ hàng:', error);
    res.status(500).json({ error: 'Lỗi server khi xoá' });
  }
};

// Clear entire cart
export const clearCart = async (req, res) => {
  try {
    const user_uid = req.user.uid;
    await prisma.cart_items.deleteMany({
      where: { user_uid }
    });
    res.status(200).json({ message: 'Đã xoá toàn bộ giỏ hàng' });
  } catch (error) {
    console.error('Lỗi xoá giỏ hàng:', error);
    res.status(500).json({ error: 'Lỗi server' });
  }
};
