package org.oscarehr.app;

import org.owasp.csrfguard.log.JavaLogger;
import org.owasp.csrfguard.log.LogLevel;
import oscar.OscarProperties;

import java.util.Arrays;
import java.util.List;

/**
 * Oscar CsrfGuardLogger
 * Extends the standard CsrfGuard JavaLogger to take into account the oscar property "csrf_log_all_messages"
 * If the property is enabled, only 
 */
public class CsrfGuardLogger extends JavaLogger {
    
    private static final OscarProperties oscarProperties = OscarProperties.getInstance();
    private static final List<LogLevel> errorLogLevels = Arrays.asList(LogLevel.Warning, LogLevel.Error, LogLevel.Fatal);
    
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
