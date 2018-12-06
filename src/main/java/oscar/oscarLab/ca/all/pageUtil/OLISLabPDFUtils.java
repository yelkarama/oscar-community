package oscar.oscarLab.ca.all.pageUtil;

import com.lowagie.text.Chunk;
import com.lowagie.text.Font;
import com.lowagie.text.Phrase;

import java.awt.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class OLISLabPDFUtils {
    
    public enum Hl7EncodedRepeatableCharacter {
        HARD_RETURN("br", "\n"),
        NEXT_LINE_ALIGN_HORIZONTAL("sp", "\n"),
        INDENT("in", " "),
        SKIP_SPACE("sk", " "),
        TEMPORARY_INDENT("ti", " ");
        
        public static final String TAG_REGEX = "\\\\\\.%s(?:([ +-])(\\d))*\\\\";
        private String hl7Tag;
        private String pdfReplacement;

        Hl7EncodedRepeatableCharacter(String hl7Tag, String pdfReplacement) {
            this.hl7Tag = hl7Tag;
            this.pdfReplacement = pdfReplacement;
        }

        public String getHl7Tag() {
            return hl7Tag;
        }
        public String getPdfReplacement() {
            return pdfReplacement;
        }
        
        public static String performReplacement(String hl7Text) {
            for (Hl7EncodedRepeatableCharacter hl7EncodedCharacter : Hl7EncodedRepeatableCharacter.values()) {
                String regex = String.format(TAG_REGEX, hl7EncodedCharacter.getHl7Tag());
                Pattern pattern = Pattern.compile(regex);
                Matcher matcher = pattern.matcher(hl7Text);
                while (matcher.find()) {
                    String repetitionsGroup = matcher.group(2);
                    int repetitions = 1;
                    if (repetitionsGroup != null) {
                        repetitions = Integer.valueOf(repetitionsGroup);
                    }

                    StringBuilder replacedText = new StringBuilder();
                    for (int i = 0; i < repetitions; i++) {
                        replacedText.append(hl7EncodedCharacter.getPdfReplacement());
                    }
                    hl7Text = hl7Text.replaceFirst(regex, replacedText.toString());
                }
            }
            return hl7Text;
        }
    }

    public enum Hl7EncodedSpan {
        HIGHLIGHT("H", "N") {
            @Override
            public Chunk createChunk(String chunkText) {
                Chunk highlightChunk = new Chunk(chunkText);
                highlightChunk.setBackground(Color.YELLOW);
                return highlightChunk;
            }
        };

        public static final String TAG_REGEX = "\\\\\\.%s\\\\(.+?)\\\\\\.%s\\\\";
        
        private String startCharacter;
        private String endCharacter;
        public abstract Chunk createChunk(String text);

        Hl7EncodedSpan(String startCharacter, String endCharacter) {
            this.startCharacter = startCharacter;
            this.endCharacter = endCharacter;
        }

        public String getStartCharacter() {
            return startCharacter;
        }
        public String getEndCharacter() {
            return endCharacter;
        }

        public static List<Chunk> createChunksFromText(String hl7Text) {
            List<Chunk> formattedTextChunks = new ArrayList<Chunk>();
            // find instances of the span start characters, create chunk for text prior to it
            // then find the end character and create a chunk with the special formatting
            for (Hl7EncodedSpan hl7EncodedSpan : Hl7EncodedSpan.values()) {
                String regex = String.format(Hl7EncodedSpan.TAG_REGEX, hl7EncodedSpan.getStartCharacter(), hl7EncodedSpan.getEndCharacter());
                Pattern pattern = Pattern.compile(regex);
                Matcher matcher = pattern.matcher(hl7Text);
                while(matcher.find()) {
                    String spanContent = matcher.group(1);
                    String beforeSpan = hl7Text.substring(0, matcher.start());
                    String afterSpan = hl7Text.substring(matcher.end());

                    formattedTextChunks.add(new Chunk(beforeSpan));
                    formattedTextChunks.add(hl7EncodedSpan.createChunk(spanContent));
                    hl7Text = afterSpan;
                }
            }
            formattedTextChunks.add(new Chunk(hl7Text));
            return formattedTextChunks;
        }
    }

    /**
     * Creates a Phrase from a string of text, adding span level markup like highlighting
     * @param hl7Text the HL7 text to parse
     * @param font the pdf font to use as a base
     * @return A phrase containing Chunks with appropriate markup
     */
    public static Phrase createPhraseFromHl7(String hl7Text, Font font) {

        Phrase phrase = new Phrase();
        phrase.setFont(font);
        // A phrase is a list of chunks, with each chunk having its own formatting
        phrase.addAll(Hl7EncodedSpan.createChunksFromText(hl7Text));

        return phrase;
    }
}