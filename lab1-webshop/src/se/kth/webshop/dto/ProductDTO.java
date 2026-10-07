package se.kth.webshop.dto;

/** Immutable snapshot for the presentation layer; contains no domain objects. */
public final class ProductDTO {
    private final int id;
    private final String name;
    private final String description;
    private final int price;

    public ProductDTO(int id, String name, String description, int price) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public int getPrice() {
        return price;
    }
}
