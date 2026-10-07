package se.kth.webshop.service;

import java.sql.SQLException;
import java.util.List;

import se.kth.webshop.dao.ProductDao;
import se.kth.webshop.dto.ProductDTO;

public class ProductService {
    private final ProductDao productDao;

    public ProductService() {
        this(new ProductDao());
    }

    ProductService(ProductDao productDao) {
        this.productDao = productDao;
    }

    public List<ProductDTO> getProducts() {
        try {
            return productDao.findAll().stream()
                    .map(product -> new ProductDTO(product.getId(),
                            product.getName(), product.getDescription(),
                            product.getPrice()))
                    .toList();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to load products.", e);
        }
    }
}
