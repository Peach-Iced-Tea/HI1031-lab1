package se.kth.webshop.model;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Cart {
    private final Map<Integer, CartItem> items = new LinkedHashMap<>();

    public Cart() {
    }

    public synchronized void add(Product product, int quantity) {
        validateQuantity(quantity);

        CartItem existing = items.get(product.getId());
        int combined = quantity;

        if (existing != null) {
            combined += existing.getQuantity();
        }

        validateQuantity(combined);
        items.put(product.getId(), new CartItem(product, combined));
    }

    public synchronized void updateQuantity(int productId, int quantity) {
        validateQuantity(quantity);

        CartItem existing = items.get(productId);

        if (existing == null) {
            throw new IllegalArgumentException("Product is not in the cart.");
        }

        items.put(productId, new CartItem(existing.getProduct(), quantity));
    }

    public synchronized void remove(int productId) {
        items.remove(productId);
    }

    public synchronized List<CartItem> getItems() {
        return List.copyOf(items.values());
    }

    public synchronized int getItemCount() {
        return items.values().stream()
                .mapToInt(CartItem::getQuantity)
                .sum();
    }

    public synchronized long getTotal() {
        return items.values().stream()
                .mapToLong(CartItem::getSubtotal)
                .sum();
    }

    private void validateQuantity(int quantity) {
        if (quantity < 1 || quantity > 99) {
            throw new IllegalArgumentException(
                "Quantity must be between 1 and 99 per product."
            );
        }
    }
}