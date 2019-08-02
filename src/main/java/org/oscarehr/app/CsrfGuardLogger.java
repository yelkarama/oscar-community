package org.oscarehr.app;

import org.owasp.csrfguard.log.JavaLogger;
import org.owasp.csrfguard.log.LogLevel;
import oscar.OscarProperties;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.logging.FileHandler;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

/**
 * Oscar CsrfGuardLogger
 * Extends the standard CsrfGuard JavaLogger to take into account the oscar property "csrf_log_all_messages"
 * If the property is enabled, only 
 */
public class CsrfGuardLogger extends JavaLogger {
    
    private static final OscarProperties oscarProperties = OscarProperties.getInstance();
    private static final List<LogLevel> errorLogLevels = Arrays.asList(LogLevel.Warning, LogLevel.Error, LogLevel.Fatal);

    // Create logger that adds to a log file in the oscar document folder just for csrf log lines
    private static Logger LOGGER = Logger.getLogger("Owasp.CsrfGuard");
    static {
        try {
            String documentsFolder = oscarProperties.getProperty("BASE_DOCUMENT_DIR");
            if (!documentsFolder.endsWith("/")) {
                documentsFolder += "/";
            }
            String logDirectory = documentsFolder + "logs";
            File logFile = new File(logDirectory + "/csrf.log");
            if (!logFile.getParentFile().exists()) {
                logFile.getParentFile().mkdirs();
            }
            FileHandler logFileHandler = new FileHandler(logFile.getPath(), true);
            logFileHandler.setFormatter(new SimpleFormatter());
            LOGGER.addHandler(logFileHandler);
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    @Override
    public void log(String msg) {
        if (isLoggable()) {
            super.log(msg);
        }
    }

    @Override
    public void log(LogLevel level, String msg) {
        if (isLoggable(level)) {
            super.log(level, msg);
        }
    }

    @Override
    public void log(Exception exception) {
        if (isLoggable()) {
            super.log(exception);
        }
    }

    @Override
    public void log(LogLevel level, Exception exception) {
        if (isLoggable(level)) {
            super.log(exception);
        }
    }

    private boolean isLoggable() {
        return oscarProperties.isPropertyActive("csrf_log_all_messages");
    }
    private boolean isLoggable(LogLevel level) {
        return oscarProperties.isPropertyActive("csrf_log_all_messages") || errorLogLevels.contains(level);
    }
}
