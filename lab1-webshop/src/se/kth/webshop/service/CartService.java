package se.kth.webshop.service;

import java.sql.SQLException;
import java.util.List;

import se.kth.webshop.dao.ProductDao;
import se.kth.webshop.dto.CartDTO;
import se.kth.webshop.dto.CartItemDTO;
import se.kth.webshop.model.Cart;
import se.kth.webshop.model.Product;

public class CartService {
    private final ProductDao productDao;
    private final Cart cart = new Cart();

    public CartService() {
        this(new ProductDao());
    }

    CartService(ProductDao productDao) {
        this.productDao = productDao;
    }

    public void add(int productId, int quantity) {
        try {
            Product product = productDao.findById(productId);

            if (product == null) {
                throw new IllegalArgumentException("Product does not exist.");
            }

            cart.add(product, quantity);
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to load product.", e);
        }
    }

    public void update(int productId, int quantity) {
        cart.updateQuantity(productId, quantity);
    }

    public void remove(int productId) {
        cart.remove(productId);
    }

    /** Copies the cart under one lock so items, count and total agree. */
    public CartDTO getSnapshot() {
        synchronized (cart) {
            List<CartItemDTO> items = cart.getItems().stream()
                    .map(item -> new CartItemDTO(
                            item.getProduct().getId(),
                            item.getProduct().getName(),
                            item.getProduct().getPrice(),
                            item.getQuantity(), item.getSubtotal()))
                    .toList();
            return new CartDTO(items, cart.getItemCount(), cart.getTotal());
        }
    }
}
