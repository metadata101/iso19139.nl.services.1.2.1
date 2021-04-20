# ISO19139 dutch service schema plugin (1.2.1)

This is the ISO iso19139 dutch service schema plugin for GeoNetwork 3.x or greater version.

More documentation at [https://github.com/metadata101/iso19139.nl.services.1.2.1]

## Reference documents:

* http://www.geonovum.nl/wegwijzer/standaarden/nederlands-metadataprofiel-op-iso-19119-services-121

## Installing the plugin

### GeoNetwork version to use with this plugin

Use GeoNetwork 3.12.

### Adding the plugin to the source code


The best approach is to add the plugin as a submodule:

1. Use [add-schema.sh](https://github.com/geonetwork/core-geonetwork/blob/3.12.x/add-schema.sh) for automatic deployment:

   ```
   ./add-schema.sh iso19139.nl.services.1.2.1 https://github.com/metadata101/iso19139.nl.services.1.2.1 3.12.x
   ```

2. Build the application:

   ```
   mvn clean install -Penv-prod -DskipTests
   ```

3. Once the application is built, the war file contains the schema plugin:

   ```
   cd web
   mvn jetty:run -Penv-dev
   ```

### Deploy the profile in an existing installation

After building the application, it's possible to deploy the schema plugin manually in an existing GeoNetwork installation:

- Copy the content of the folder schemas/iso19139.nl.services.1.2.1/src/main/plugin to INSTALL_DIR/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.nl.services.1.2.1

- Copy the jar file schemas/iso19139.nl.geografie.2.0.0/target/schema-iso19139.nl.services.1.2.1-3.12.jar to INSTALL_DIR/geonetwork/WEB-INF/lib.

If there's no changes to the profile Java code or the configuration (config-spring-geonetwork.xml), the jar file is not required to be deployed each time.
