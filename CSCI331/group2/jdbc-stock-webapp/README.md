# JDBC Stock Web App Skeleton

This is a lightweight Java project skeleton for a stock-search web app.

## What is included
- A plain Java HTTP server using `com.sun.net.httpserver.HttpServer`
- A minimalist homepage with:
  - collapsible left sidebar
  - centered stock search bar
  - clean styling
- A search results page shell that reads the query string and displays the searched symbol/name
- JDBC-oriented package structure for future database integration

## Why this structure
This avoids requiring Tomcat, JSP, Maven, Gradle, or IntelliJ just to see the homepage.
You can run it with only the JDK.

## Run
From the project root:

```bat
javac -d out src\com\example\stockapp\config\*.java src\com\example\stockapp\db\*.java src\com\example\stockapp\server\*.java
java -cp out com.example.stockapp.server.MainServer
```

Then open:

```text
http://localhost:8080/
```

## Next logical steps
- Add an `/api/search` endpoint in Java
- Call Alpaca from the server side
- Store search history, watchlists, or mock trades with JDBC
- Add login/session handling later
