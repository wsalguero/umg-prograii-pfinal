# Hoteles App

## video demo

https://drive.google.com/file/d/16baY0FKA11Cq74s80ywpwoxlUy4WiCbD/view?usp=drive_link

### Setup

Para crear el proyecto se utilizan el comando

_IMPORTANT:_ [proyecto] sustituirlo por el nombre real a usar

```powershel

mvn org.apache.maven.plugins:maven-archetype-plugin:3.2.1:generate `-DgroupId=com.umg ` -DartifactId=[proyecto] `-DarchetypeGroupId=org.apache.maven.archetypes `  -DarchetypeArtifactId=maven-archetype-webapp `  -DinteractiveMode=false

```

```powershel

cd [proyecto]

```

Se agregan los plugins al archivo pom.xml para la utlizacion de Jetty como servidor para el ambiente local

```xml

<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.umg</groupId>
  <artifactId>pagina-web</artifactId>
  <version>1.0.0</version>
  <packaging>war</packaging>
  <name>pagina-web</name>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <!-- Jetty 9 usa javax.servlet (más fácil para JSP sencillos) -->
    <jetty.version>9.4.54.v20240208</jetty.version>
  </properties>

  <dependencies>
    <!-- API Servlet (solo en tiempo de compilación; el contenedor la provee) -->
    <dependency>
      <groupId>javax.servlet</groupId>
      <artifactId>javax.servlet-api</artifactId>
      <version>4.0.1</version>
      <scope>provided</scope>
    </dependency>
    <!-- JSTL (opcional, por si quieres usar <c:...> en JSP) -->
    <dependency>
      <groupId>javax.servlet</groupId>
      <artifactId>jstl</artifactId>
      <version>1.2</version>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <!-- Empaquetar WAR -->
      <plugin>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.4.0</version>
        <configuration>
          <failOnMissingWebXml>false</failOnMissingWebXml>
        </configuration>
      </plugin>

      <!-- Ejecutar con Jetty sin instalar nada extra -->
      <plugin>
        <groupId>org.eclipse.jetty</groupId>
        <artifactId>jetty-maven-plugin</artifactId>
        <version>${jetty.version}</version>
        <configuration>
          <scanIntervalSeconds>2</scanIntervalSeconds>
          <webApp>
            <contextPath>/pagina-web</contextPath>
          </webApp>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>


```

Y para correr el proyecto se ejecuta el siguiente comando, importante tener maven instalado antes de empezar a usarlo

Instalar maven

https://maven-apache-org.translate.goog/install.html?_x_tr_sl=en&_x_tr_tl=es&_x_tr_hl=es&_x_tr_pto=tc

```powershel
cd pagina-web
mvn jetty:run

```

La aplicacion empezara a correr en el puerto

localhost:8080
