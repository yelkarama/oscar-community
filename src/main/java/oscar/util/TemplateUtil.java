package oscar.util;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import org.apache.log4j.Logger;
import org.oscarehr.util.MiscUtils;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.util.Map;

public class TemplateUtil {
    private static Configuration cfg;
    private static Logger logger = MiscUtils.getLogger();
    
    static {
        cfg = new Configuration(Configuration.VERSION_2_3_28);
        cfg.setDefaultEncoding(StandardCharsets.UTF_8.name());
    }
    
    public static String performTemplateReplace(String templateData, Map<String, String> templateValues) throws IOException, TemplateException {
        String formattedTemplate;
        Template template = new Template("template", new StringReader(templateData), cfg);
        
        try (StringWriter out = new StringWriter()) {
            template.process(templateValues, out);
            formattedTemplate = out.toString();
        }
        
        return formattedTemplate;
    }
}
