package com.example.stockapp.server;

import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;

public class MainServer {
    public static void main(String[] args) throws IOException {
        int port = 8080;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

        server.createContext("/", new StaticFileHandler("web"));
        server.setExecutor(Executors.newFixedThreadPool(8));
        server.start();

        System.out.println("Server running at http://localhost:" + port + "/");
    }
}
