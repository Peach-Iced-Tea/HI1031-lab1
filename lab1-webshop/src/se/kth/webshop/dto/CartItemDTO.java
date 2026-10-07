package se.kth.webshop.dto;

/** Immutable snapshot for the presentation layer; contains no domain objects. */
public final class CartItemDTO {
    private final int productId;
    private final String name;
    private final int price;
    private final int quantity;
    private final long subtotal;

    public CartItemDTO(int productId, String name, int price, int quantity, long subtotal) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
        this.subtotal = subtotal;
    }

    public int getProductId() {
        return productId;
    }

    public String getName() {
        return name;
    }

    public int getPrice() {
        return price;
    }

    public int getQuantity() {
        return quantity;
    }

    public long getSubtotal() {
        return subtotal;
    }
}
