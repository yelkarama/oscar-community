<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cog="http://developer.cognos.com/schemas/xmldata/1/">
    <xsl:param name="groupNo"/>
    <xsl:param name="providerBillNo"/>
    <xsl:param name="providerName"/>
    <xsl:param name="reportDate"/>
   
    <xsl:template match="/">
        <html>
            <body>
                <div id="Title" class="Header1">
                    Roster and Capitation Payment Reconciliation
                </div>
                <table border="0" width="25%" cellspacing="0" cellpadding="1">
                    <tr>
                        <td>Report:</td>
                        <td>RCX</td>
                    </tr>

                    <tr>
                        <td>Group #:</td>
                        <td><xsl:value-of select="$groupNo"/></td>
                    </tr>

                    <tr>
                        <td>Provider:</td>
                        <td><xsl:value-of select="$providerName"/></td>
                    </tr>

                    <tr>
                        <td>Provider Bill No:</td>
                        <td><xsl:value-of select="$providerBillNo"/></td>
                    </tr>

                    <tr>
                        <td>Report Date:</td>
                        <td><xsl:value-of select="$reportDate"/></td>
                    </tr>
                </table>

                <p></p>

                <data>
                    <!--ROSTER SUMMARY -->
                    <h6 style="margin: 0;"><xsl:value-of select="//cog:row[1]/cog:value[1]/text()"/></h6>
                    <table border="1" width="50%" cellspacing="0" cellpadding="1" id="rosterSummary" style="font-family:Arial;font-size:10pt">
                        <tr>
                            <th width="205px" class="dataBlock" align="left"><xsl:value-of select="//cog:row[2]/cog:value[1]/text()"/></th>
                            <td class="dataBlack" align="left"><xsl:value-of select="//cog:row[2]/cog:value[2]/text()"/></td>
                        </tr>
                        <tr>
                            <th width="205px" class="dataBlock" align="left"><xsl:value-of select="//cog:row[3]/cog:value[1]/text()"/></th>
                            <td class="dataBlack" align="left"><xsl:value-of select="//cog:row[3]/cog:value[2]/text()"/></td>
                        </tr>
                        <tr>
                            <th width="205px" class="dataBlock" align="left"><xsl:value-of select="//cog:row[4]/cog:value[1]/text()"/></th>
                            <td class="dataBlack" align="left"><xsl:value-of select="//cog:row[4]/cog:value[2]/text()"/></td>
                        </tr>
                        <tr>
                            <th width="205px" class="dataBlock" align="left"><xsl:value-of select="//cog:row[5]/cog:value[1]/text()"/></th>
                            <td class="dataBlack" align="left"><xsl:value-of select="//cog:row[5]/cog:value[2]/text()"/></td>
                        </tr>
                    </table>
                    
                    <!--PENDING TRANSFER-->
                    <h4>Pending Transfer</h4>
                    <table border="1" width="100%" cellspacing="0" cellpadding="1" id="pendingTransfer" style="font-family:Arial;font-size:10pt">
                        <tr>
                            <xsl:for-each select="/cog:dataset/cog:metadata/cog:item">
                                <th><xsl:value-of select="@name"/></th>
                            </xsl:for-each>
                        </tr>
                    </table>


                    <!--NEWLY ROSTERED-->
                    <h4>Newly Rostered</h4>
                    <table border="1" width="100%" cellspacing="0" cellpadding="1" id="newlyRostered" style="font-family:Arial;font-size:10pt">
                        <tr>
                            <xsl:for-each select="/cog:dataset/cog:metadata/cog:item">
                                <th><xsl:value-of select="@name"/></th>
                            </xsl:for-each>
                        </tr>
                    </table>

                    <!--TERMINATED-->
                    <h4>Terminated</h4>
                    <table border="1" width="100%" cellspacing="0" cellpadding="1" id="terminated" style="font-family:Arial;font-size:10pt">
                        <tr>
                            <xsl:for-each select="/cog:dataset/cog:metadata/cog:item">
                                <th><xsl:value-of select="@name"/></th>
                            </xsl:for-each>
                        </tr>
                        
                    </table>

                    <!--MISSING FROM EMR-->
                    <h4>Missing From EMR</h4>
                    <table border="1" width="100%" cellspacing="0" cellpadding="1" id="missing" style="font-family:Arial;font-size:10pt">
                        <tr>
                            <xsl:for-each select="/cog:dataset/cog:metadata/cog:item">
                                <th><xsl:value-of select="@name"/></th>
                            </xsl:for-each>
                        </tr>
                    </table>

                    <!--Existing-->
                    <h4>Existing Demographics</h4>
                    <table border="1" width="100%" cellspacing="0" cellpadding="1" id="existing" style="font-family:Arial;font-size:10pt">
                        <tr>
                            <xsl:for-each select="/cog:dataset/cog:metadata/cog:item">
                                <th><xsl:value-of select="@name"/></th>
                            </xsl:for-each>
                        </tr>
                    </table>
                </data>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>