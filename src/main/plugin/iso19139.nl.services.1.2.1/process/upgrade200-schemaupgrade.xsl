<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:java="java:org.fao.geonet.util.XslUtil" version="2.0"
                exclude-result-prefixes="#all">

  <xsl:import href="process-utility.xsl"/>


  <!-- i18n information -->
  <xsl:variable name="upgrade-schema-version-loc">
    <msg id="a" xml:lang="eng">Update metadata to Nederlands metadataprofiel op ISO 19119 voor services 2.0.0</msg>
    <msg id="a" xml:lang="dut">Update metadata to Nederlands metadataprofiel op ISO 19119 voor services 2.0.0</msg>
  </xsl:variable>

  <xsl:template name="list-upgrade200-schemaupgrade">
    <suggestion process="upgrade200-schemaupgrade"/>
  </xsl:template>

  <!-- Analyze the metadata record and return available suggestion
    for that process -->
  <xsl:template name="analyze-upgrade200-schemaupgrade">
    <xsl:param name="root"/>
      <suggestion process="upgrade200-schemaupgrade" id="{generate-id()}" category="keyword"
                  target="keyword">
        <name xml:lang="en">
          <xsl:value-of select="geonet:i18n($upgrade-schema-version-loc, 'a', $guiLang)"/>
        </name>
        <operational>true</operational>
        <form/>
      </suggestion>

  </xsl:template>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Always remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>


  <!-- Update metadataStandardVersion -->
  <xsl:template match="gmd:metadataStandardVersion" priority="2">
      <gmd:metadataStandardVersion>
        <gco:CharacterString>Nederlands metadata profiel op ISO 19119 voor services 2.0</gco:CharacterString>
      </gmd:metadataStandardVersion>
  </xsl:template>

</xsl:stylesheet>
