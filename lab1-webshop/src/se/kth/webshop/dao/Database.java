package se.kth.webshop.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Database {

    private Database() {
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL JDBC driver is missing.", e);
        }

        return DriverManager.getConnection(
            requiredEnvironmentVariable("DB_URL"),
            requiredEnvironmentVariable("DB_USER"),
            requiredEnvironmentVariable("DB_PASSWORD")
        );
    }

    private static String requiredEnvironmentVariable(String name) {
        String value = System.getenv(name);

        if (value == null || value.isBlank()) {
            throw new IllegalStateException(
                "Missing environment variable: " + name
            );
        }

        return value;
    }
}