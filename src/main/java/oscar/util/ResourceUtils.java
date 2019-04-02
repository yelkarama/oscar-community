package oscar.util;

import java.net.URISyntaxException;

public class ResourceUtils {
    public enum Font {
        COURIER_PRIME("Courier Prime.ttf"),
        COURIER_PRIME_BOLD("Courier Prime Bold.ttf");
        
        private final String FONT_PATH = "oscar/fonts/";
        private String fileName;
        
        Font(String fileName) {
            this.fileName = fileName;
        }

        /**
         * Gets the path for the font, returning the full system path to the resource 
         * allowing it to be accessed
         * 
         * @return String containing the full system resource path
         * @throws URISyntaxException Thrown when the path provided is incorrect
         */
        public String getPath() throws URISyntaxException {
            return ResourceUtils.getResourcePath(FONT_PATH + fileName);
        }
    }

    /**
     * Gets the path for a desired resourse using the provided resource folder path.
     * This will find the resource and return the full system path, allowing access to the file
     * 
     * @param path the path in the resource folder to get the full system path for
     * @return String containing the full system path to the desired resource
     * @throws URISyntaxException Thrown when the path provided is incorrect
     */
    public static String getResourcePath(String path) throws URISyntaxException {
        return ResourceUtils.class.getClassLoader().getResource(path).toURI().getPath();
    }
}
