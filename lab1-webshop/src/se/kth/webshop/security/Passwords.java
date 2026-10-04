package se.kth.webshop.security;

import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public final class Passwords {
    private static final int ITERATIONS = 600_000;

    private Passwords() {
    }

    public static String hash(char[] password) {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);

        byte[] hash = derive(password, salt);

        return Base64.getEncoder().encodeToString(salt)
                + ":" + Base64.getEncoder().encodeToString(hash);
    }

    public static boolean verify(char[] password, String stored) {
        String[] parts = stored.split(":");

        if (parts.length != 2) {
            throw new IllegalStateException("Invalid stored password format.");
        }

        byte[] salt = Base64.getDecoder().decode(parts[0]);
        byte[] expected = Base64.getDecoder().decode(parts[1]);
        byte[] actual = derive(password, salt);

        return MessageDigest.isEqual(expected, actual);
    }

    private static byte[] derive(char[] password, byte[] salt) {
        PBEKeySpec specification =
                new PBEKeySpec(password, salt, ITERATIONS, 256);

        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
                    .generateSecret(specification)
                    .getEncoded();
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("Password hashing failed.", e);
        } finally {
            specification.clearPassword();
        }
    }

    // Run from a terminal to generate a hash for a test account.
    public static void main(String[] args) {
        var console = System.console();

        if (console == null) {
            throw new IllegalStateException(
                "Run this class from a terminal."
            );
        }

        char[] password = console.readPassword("Test account password: ");

        if (password == null || password.length == 0) {
            throw new IllegalArgumentException("Password cannot be empty.");
        }

        try {
            System.out.println(hash(password));
        } finally {
            Arrays.fill(password, '\0');
        }
    }
}