package se.kth.webshop.service;

import java.sql.SQLException;
import java.util.List;

import se.kth.webshop.dao.ProductDao;
import se.kth.webshop.model.Product;

public class ProductService {
    private final ProductDao productDao;

    public ProductService() {
        productDao = new ProductDao();
    }

    public List<Product> getProducts() {
        try {
            return productDao.findAll();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to load products.", e);
        }
    }
}