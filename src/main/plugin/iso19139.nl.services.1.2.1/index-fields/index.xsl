<?xml version="1.0" encoding="UTF-8" ?>
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
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:daobs="http://daobs.org"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="../../iso19139/index-fields/index.xsl" />


  <xsl:template match="*" mode="index-extra-fields">

    <xsl:if test="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset'
          and
            (not (
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'download')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'dataset')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'WFS')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'WCS')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'CSW')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'SOS')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'INSPIRE Atom')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'WMTS')] or
              gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString[contains(., 'WMS')]
              )
              and not (
              //srv:serviceType/gco:LocalName[contains(., 'download')] or
              //srv:serviceType/gco:LocalName[contains(., 'dataset')] or
              //srv:serviceType/gco:LocalName[contains(., 'WFS')] or
              //srv:serviceType/gco:LocalName[contains(., 'WCS')] or
              //srv:serviceType/gco:LocalName[contains(., 'CSW')] or
              //srv:serviceType/gco:LocalName[contains(., 'SOS')] or
              //srv:serviceType/gco:LocalName[contains(., 'INSPIRE Atom')] or
              //srv:serviceType/gco:LocalName[contains(., 'WMTS')] or
              //srv:serviceType/gco:LocalName[contains(., 'WMS')]
              )
            )">
      <nodynamicdownload>true</nodynamicdownload>
    </xsl:if>

    <xsl:variable name="isDownloadableService">
      <xsl:for-each select="srv:serviceType/gco:LocalName">
        <xsl:if test=". = 'download'">
          downloadable
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="isDownloadable">
      <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>
        <xsl:variable name="protocol" select="gmd:protocol/*/text()"/>

        <xsl:variable name="wfsLinkNoProtocol"
                      select="contains(lower-case($linkage), 'service=wfs') and not(string($protocol))"/>
        <xsl:variable name="wcsLinkNoProtocol"
                      select="contains(lower-case($linkage), 'service=wcs') and not(string($protocol))"/>

        <xsl:if
          test="contains($protocol, 'WWW:DOWNLOAD') or contains($protocol, 'OGC:WFS') or contains($protocol, 'OGC:WCS') or
                contains($protocol, 'OGC:SOS') or contains($protocol, 'INSPIRE Atom') or $wfsLinkNoProtocol or $wcsLinkNoProtocol">
          downloadable
        </xsl:if>

      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="isDynamicService">
      <xsl:for-each select="srv:serviceType/gco:LocalName">
        <xsl:if test=". = 'view'">
          dynamic
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="isDynamic">
      <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>
        <xsl:variable name="protocol" select="gmd:protocol/*/text()"/>

        <xsl:variable name="wmsLinkNoProtocol"
                      select="contains(lower-case($linkage), 'service=wms') and not(string($protocol))"/>
        <xsl:variable name="wmtsLinkNoProtocol"
                      select="contains(lower-case($linkage), 'service=wmts') and not(string($protocol))"/>

        <xsl:if
          test="contains(., 'OGC:WMS') or contains(., 'OGC:WMTS') or $wmsLinkNoProtocol or $wmtsLinkNoProtocol">
          dynamic
        </xsl:if>

      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="string(normalize-space($isDownloadableService)) or string(normalize-space($isDownloadable))">
      <download>true</download>
    </xsl:if>

    <xsl:if test="string(normalize-space($isDynamicService)) or string(normalize-space($isDynamic))">
      <dynamic>true</dynamic>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
