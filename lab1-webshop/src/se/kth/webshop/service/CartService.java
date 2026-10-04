package se.kth.webshop.service;

import java.sql.SQLException;

import se.kth.webshop.dao.ProductDao;
import se.kth.webshop.model.Cart;
import se.kth.webshop.model.Product;

public class CartService {
    private final ProductDao productDao = new ProductDao();

    public CartService() {
    }

    public void add(Cart cart, int productId, int quantity) {
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

    public void update(Cart cart, int productId, int quantity) {
        cart.updateQuantity(productId, quantity);
    }

    public void remove(Cart cart, int productId) {
        cart.remove(productId);
    }
}