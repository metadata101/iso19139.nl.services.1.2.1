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
  xmlns:exslt="http://exslt.org/common" 
  xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:wfs="http://www.opengis.net/wfs"
  xmlns:wfs20="http://www.opengis.net/wfs/2.0"
  xmlns:wcs="http://www.opengis.net/wcs"
  xmlns:wmts="http://www.opengis.net/wmts/1.0"
  xmlns:wms="http://www.opengis.net/wms"
  xmlns:ows="http://www.opengis.net/ows"
  xmlns:owsg="http://www.opengeospatial.net/ows"
  xmlns:ows11="http://www.opengis.net/ows/1.1"
  xmlns:wps="http://www.opengeospatial.net/wps"
  xmlns:wps1="http://www.opengis.net/wps/1.0.0"
  xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0"
  xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0" 
  version="2.0"
  exclude-result-prefixes="#all">

  <xsl:import href="../../iso19139/process/process-utility.xsl"/>
  
  <!-- i18n information -->
  <xsl:variable name="wxs-info-loc-nl">
    <msg id="a" xml:lang="eng">OGC WMS or WFS service </msg>
    <msg id="b" xml:lang="eng"> is described in online resource section. Run this process to add operations information</msg>
	<msg id="a" xml:lang="dut">Gekoppelde datasets overnemen uit WMS-, WMTS- of WFS-capabilities van </msg>
    <msg id="b" xml:lang="dut">. Let op: bestaande operaties en dataset koppelingen in de metadata worden overschreven met de waarden uit het capabilities document. Bestaande operaties en datakoppelingen worden verwijderd als lagen in het capabilities document niet juist geidentificeerd zijn (ows:identifier).</msg>
    <msg id="a" xml:lang="fre">Le service WMS ou WFS </msg>
    <msg id="b" xml:lang="fre"> est décrit dans la section resource en ligne. Exécuter cette action pour ajouter ou remplacer les informations relatives aux opérations</msg>
  </xsl:variable>

  <!-- Process parameters and variables-->
  <xsl:param name="wxsServiceUrl"/>
  
  <!-- Load the capabilities document if one oneline resource contains a protocol set to WMS or WFS
    Check if containsOperation element is already defined
  -->
  <xsl:variable name="wxsOnlineNodesnl"
    select="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine//gmd:CI_OnlineResource[(
    contains(gmd:protocol/gco:CharacterString, 'OGC:WMS')
    or contains(gmd:protocol/gco:CharacterString, 'OGC:WMTS')
    or contains(gmd:protocol/gco:CharacterString, 'OGC:WFS')
    ) and contains(gmd:linkage/gmd:URL,$wxsServiceUrl)]"/>
  <xsl:variable name="wxsProtocolnl" select="$wxsOnlineNodesnl/gmd:protocol[1]/gco:CharacterString"/>
  
  <xsl:variable name="wxsCapabilitiesDoc">
    <xsl:if test="$wxsOnlineNodesnl">
      <xsl:choose>
        <xsl:when test="contains($wxsProtocolnl, 'WMS')">
          <xsl:copy-of select="geonet:get-wxs-capabilities($wxsServiceUrl, 'WMS', '1.3.0')"/>
        </xsl:when>
        <xsl:when test="contains($wxsProtocolnl, 'WMTS')">
          <xsl:copy-of select="geonet:get-wxs-capabilities($wxsServiceUrl, 'WMTS', '1.0')"/>
        </xsl:when>
        <xsl:when test="contains($wxsProtocolnl, 'WFS')">
          <xsl:copy-of select="geonet:get-wxs-capabilities($wxsServiceUrl, 'WFS', '1.1.0')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>process:add-service-info-from-wxs-nl: Unsupported protocol '<xsl:value-of select="$wxsProtocolnl"/>'.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:variable>

  <xsl:template name="list-add-service-info-from-wxs-nl">
    <suggestion process="add-service-info-from-wxs-nl"/>
  </xsl:template>


  <!-- Analyze the metadata record and return available suggestion
    for that process -->
  <xsl:template name="analyze-add-service-info-from-wxs-nl">

    <xsl:param name="root"/>
    
    <xsl:variable name="srv"
      select="$root//*[local-name(.)='SV_ServiceIdentification' or contains(@gco:isoType, 'SV_ServiceIdentification')]"/>
    
    <xsl:variable name="onlineResources"
      select="$root//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[(
        contains(gmd:protocol/gco:CharacterString, 'OGC:WMS') 
        or contains(gmd:protocol/gco:CharacterString, 'OGC:WMTS')
        or contains(gmd:protocol/gco:CharacterString, 'OGC:WFS')) 
           and normalize-space(gmd:linkage/gmd:URL)!='']"/>

    <xsl:if test="$srv"><!-- Only apply to service metadata-->
      <xsl:for-each select="$onlineResources">
        <suggestion process="add-service-info-from-wxs-nl" id="{generate-id()}-service" category="onlineSrc" target="srv:containsOperations">
          <name><xsl:value-of select="geonet:i18n($wxs-info-loc-nl, 'a', $guiLang)"/><xsl:value-of select="./gmd:linkage/gmd:URL"
          /><xsl:value-of select="geonet:i18n($wxs-info-loc-nl, 'b', $guiLang)"/>.</name>
          <operational>true</operational>
          <params>{ 
              wxsServiceUrl:{type:'string', defaultValue:'<xsl:value-of select="normalize-space(gmd:linkage/gmd:URL)"/>'}
            }</params>
        </suggestion>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>


  <!-- Processing templates -->
  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>


  <!-- Here loop through layers/featuretypes -->
  <xsl:template
    match="gmd:identificationInfo/*"
    priority="2">
  
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- Copy all elements from AbstractMD_IdentificationType-->
      <xsl:copy-of
        select="gmd:*"/>


      <!-- Service -->
      <xsl:copy-of
        select="srv:serviceType|
                srv:serviceTypeVersion|
                srv:accessProperties|
                srv:restrictions|
                srv:keywords|
                srv:extent"/>



    <xsl:for-each select="$wxsCapabilitiesDoc//Layer|$wxsCapabilitiesDoc//wms:Layer|$wxsCapabilitiesDoc//wmts:Layer|$wxsCapabilitiesDoc//ows11:Layer|$wxsCapabilitiesDoc//wfs:FeatureType">
      <!-- todo: wfs inspire featuretype -->
  <!-- if inspire, extract the ds identifier from extended capabilities -->
<!-- use the nth identifier as featuretype identifier, better to look via md-uuid in ds-md to find identifier, if not use default identifier -->

        <xsl:variable name="Identifier" select="Identifier[1]|wms:Identifier[1]|wmts:Identifier[1]|ows11:Identifier[1]|../../ows:OperationsMetadata/ows:ExtendedCapabilities/inspire_dls:ExtendedCapabilities/inspire_dls:SpatialDataSetIdentifier[1]/inspire_common:Code"></xsl:variable>
        <xsl:variable name="Authority" select="Identifier[1]/@authority|wms:Identifier[1]/@authority|ows11:Identifier[1]/@authority|../../ows:OperationsMetadata/ows:ExtendedCapabilities/inspire_dls:ExtendedCapabilities/inspire_dls:SpatialDataSetIdentifier[1]/inspire_common:Namespace"></xsl:variable>

   <!--<xsl:message><xsl:value-of select="position()"/>/
   <xsl:value-of select="$Identifier"/>/
   <xsl:value-of select="$Authority"/></xsl:message> -->    
     
        <xsl:variable name="mdName" select="name|wms:Name|wmts:Name|ows11:Name|ows11:Title|wfs:Name"/>
        <xsl:variable name="mdTitle" select="Title|wms:Title|ows11:Title|wfs:Title"/>

        

        <xsl:if test="$mdName!=''">
          <srv:coupledResource>
            <srv:SV_CoupledResource>
              <srv:operationName>
                <gco:CharacterString>
                  <xsl:choose>
                    <xsl:when test="namespace-uri(.)='http://www.opengis.net/wms'">GetMap</xsl:when>
                    <xsl:when test="namespace-uri(.)='http://www.opengis.net/wmts/1.0'">GetTile</xsl:when>
                    <xsl:when test="namespace-uri(.)='http://www.opengis.net/wfs'">GetFeature</xsl:when>
                    <xsl:otherwise>GetCapabilities
                    </xsl:otherwise>
                  </xsl:choose>
                </gco:CharacterString><!-- todo: should be gettile for wmts -->
              </srv:operationName>
              <srv:identifier>
                <gco:CharacterString><xsl:value-of select="$Identifier"/></gco:CharacterString>
              </srv:identifier>
              <gco:ScopedName codeSpace="{$Authority}"><xsl:value-of select="$mdName"/></gco:ScopedName>
            </srv:SV_CoupledResource>
          </srv:coupledResource>
        </xsl:if>
      </xsl:for-each>

      <xsl:copy-of
        select="srv:couplingType
                "/>
      <!-- Adding contains operation info -->

        <xsl:copy-of select="srv:containsOperations"/>
  
        
      <!-- <xsl:for-each select="$wxsCapabilitiesDoc//Request/*|
        $wxsCapabilitiesDoc//wfs:Request/*|
        $wxsCapabilitiesDoc//wms:Request/*|
        $wxsCapabilitiesDoc//wmts:Request/*|
        $wxsCapabilitiesDoc//wcs:Request/*|
        $wxsCapabilitiesDoc//ows:OperationsMetadata/ows:Operation|
        $wxsCapabilitiesDoc//ows11:OperationsMetadata/ows11:Operation|
        $wxsCapabilitiesDoc//wps:ProcessOfferings/*|
        $wxsCapabilitiesDoc//wps1:ProcessOfferings/*">
        Some services provide information about ows:ExtendedCapabilities TODO ?
        
      <xsl:variable name="ows">
        <xsl:choose>
          <xsl:when test="namespace-uri(.)='http://www.opengis.net/ows' or
                          namespace-uri(.)='http://www.opengeospatial.net/ows'  or
                          namespace-uri(.)='http://www.opengis.net/ows/1.1'">true</xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:variable> -->

       <!-- <srv:containsOperations>
          <srv:SV_OperationMetadata>
            <srv:operationName>
              <gco:CharacterString>
                <xsl:choose>
                  <xsl:when test="name(.)='wps:Process'">WPS Process: <xsl:value-of select="ows:Title|ows11:Title"/></xsl:when>
                  <xsl:when test="$ows='true'"><xsl:value-of select="@name"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="name(.)"/></xsl:otherwise>
                </xsl:choose>
              </gco:CharacterString>
            </srv:operationName>-->
            <!--  CHECKME : DCPType/SOAP ?
            <xsl:for-each select="DCPType/HTTP/*|wfs:DCPType/wfs:HTTP/*|wms:DCPType/wms:HTTP/*|
            wcs:DCPType/wcs:HTTP/*|ows:DCP/ows:HTTP/*|ows11:DCP/ows11:HTTP/*"> 
              <srv:DCP>
                <srv:DCPList codeList="http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue="WebServices"/>
              </srv:DCP>
            </xsl:for-each>-->
            
          <!--  <xsl:if test="name(.)='wps:Process' or name(.)='wps11:ProcessOfferings'">
              <srv:operationDescription>
                <gco:CharacterString><xsl:value-of select="ows:Abstract|ows11:Abstract"/></gco:CharacterString> 
              </srv:operationDescription> 
              <srv:invocationName>
                <gco:CharacterString><xsl:value-of select="ows:Identifier|ows11:Identifier"/></gco:CharacterString> 
              </srv:invocationName> 
            </xsl:if>
      
            <xsl:for-each select="Format|wms:Format|ows:Parameter[@name='AcceptFormats' or @name='outputFormat']">
              <srv:connectPoint>
                <gmd:CI_OnlineResource>
                  <gmd:linkage>
                    <gmd:URL>
                      <xsl:choose>
                        <xsl:when test="$ows='true'">
                          <xsl:value-of select="..//ows:Get[1]/@xlink:href"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="..//*[1]/OnlineResource/@xlink:href|..//*[1]/wms:OnlineResource/@xlink:href"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </gmd:URL>
                  </gmd:linkage>
                  <gmd:protocol>
                    <gco:CharacterString><xsl:value-of select="$wxsProtocol"/></gco:CharacterString>
                  </gmd:protocol>
                  <gmd:description>
                    <gco:CharacterString>
                      Format : <xsl:value-of select="."/>
                    </gco:CharacterString>
                  </gmd:description>
                  <gmd:function>
                    <gmd:CI_OnLineFunctionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode" codeListValue="information"/>
                  </gmd:function>
                </gmd:CI_OnlineResource>
              </srv:connectPoint>
            </xsl:for-each>-->
            
            
            <!-- Some Operations in WFS 1.0.0 have no ResultFormat no CI_OnlineResource created 
              WCS has no output format
           
            <xsl:for-each select="wfs:ResultFormat/*">
              <srv:connectPoint>
                <gmd:CI_OnlineResource>
                  <gmd:linkage>
                    <gmd:URL><xsl:value-of select="../..//wfs:Get[1]/@onlineResource"/></gmd:URL>
                  </gmd:linkage>
                  <gmd:protocol>
                    <gco:CharacterString><xsl:value-of select="name(.)"/></gco:CharacterString>
                  </gmd:protocol>
                  <gmd:function>
                    <gmd:CI_OnLineFunctionCode codeList="./resources/codeList.xml#CI_OnLineFunctionCode" codeListValue="information"/>
                  </gmd:function>
                </gmd:CI_OnlineResource>
              </srv:connectPoint>
            </xsl:for-each>
          </srv:SV_OperationMetadata>
        </srv:containsOperations> 
      </xsl:for-each>-->
      
      <!-- End of service 
      <xsl:copy-of select="srv:operatesOn" />-->
      <!-- todo: remove operateson to replace -->

  

    <xsl:for-each select="$wxsCapabilitiesDoc//Layer|$wxsCapabilitiesDoc//wms:Layer|$wxsCapabilitiesDoc//wmts:Layer|$wxsCapabilitiesDoc//ows11:Layer|$wxsCapabilitiesDoc//wfs:FeatureType">
      <!-- todo: wfs inspire featuretype -->
        
        <xsl:variable name="mdName" 
          select="name|wms:Name|ows11:Name|ows11:Title|wfs:Name|wfs20:Name"/>
          <xsl:variable name="mdTitle" 
          select="Title|wms:Title|ows11:Title|wfs:Title|wfs20:Title"/>
          <!-- get authority url from this or fom root layer
        <AuthorityURL name="NL.HWH">
        <OnlineResource xlink:type="simple" xlink:href="http://www.hetwaterschapshuis.nl"/>
        </AuthorityURL>
        -->
        <!-- get object reference
          <Identifier authority="NL.HWH">b08fc2d0-f9a0-11e0-be50-0800200c9a66</Identifier>
          <AuthorityURL name="NL.HWH">
            <OnlineResource xlink:type="simple" xlink:href="http://www.hetwaterschapshuis.nl"/>
          </AuthorityURL>
        -->
        
  <!-- if inspire, extract the ds identifier from extended capabilities -->
<!-- use the nth identifier as featuretype identifier, better to look via md-uuid in ds-md to find identifier, if not use default identifier -->
         
        <xsl:variable name="Identifier" select="Identifier[1]|wms:Identifier[1]|wmts:Identifier[1]|ows11:Identifier[1]|../../ows:OperationsMetadata/ows:ExtendedCapabilities/inspire_dls:ExtendedCapabilities/inspire_dls:SpatialDataSetIdentifier[1]/inspire_common:Code"></xsl:variable>
        <xsl:variable name="Authority" select="Identifier[1]/@authority|wms:Identifier[1]/@authority|ows11:Identifier[1]/@authority|../../ows:OperationsMetadata/ows:ExtendedCapabilities/inspire_dls:ExtendedCapabilities/inspire_dls:SpatialDataSetIdentifier[1]/inspire_common:Namespace"></xsl:variable>
        <!-- metadata url(s)  
        <MetadataURL type="TC211">
          <Format>application/xml</Format>
          <OnlineResource xlink:type="simple" xlink:href="http://www.nationaalgeoregister.nl/geonetwork/srv/nl/csw?Service=CSW&Request=GetRecordById&Version=2.0.2&outputSchema=http://www.isotc211.org/2005/gmd&elementSetName=full&id=3ac97da7-acaf-4e30-bc77-a09186e96bf0"/>
          </MetadataURL>

          md-url may be 
        -->
        <xsl:variable name="mdURL" 
          select="replace(replace(MetadataURL[1]/OnlineResource/@xlink:href|
          wms:MetadataURL[1]/wms:OnlineResource/@xlink:href|
          wmts:MetadataURL[1]/wms:OnlineResource/@xlink:href|
          wfs:MetadataURL[1]|
          wfs20:MetadataURL[1]/@xlink:href|
          ows11:MetadataURL[1]/ows11:OnlineResource/@xlink:href,'%7B','{'),'%7D','}')"></xsl:variable>
        
        <!-- create operatesOnelement -->
        <!-- todo: if mdurl is empty, then check what is md-identifier of ds-identifier and use to create md url-->
        <!-- todo: if ds-identifier is empty, then check what is ds-identifier of md-identifier and use to create md url-->
        <xsl:if test="$mdURL or $Identifier">
        <srv:operatesOn xlink:href="{$mdURL}" uuidref="{$Identifier}" />
        </xsl:if>
        
      </xsl:for-each>

      <!-- Note: When applying this stylesheet
            to an ISO profil having a new substitute for
            MD_Identification, profil specific element copy.
            -->
      <xsl:for-each
        select="*[namespace-uri()!='http://www.isotc211.org/2005/gmd' 
              and namespace-uri()!='http://www.isotc211.org/2005/srv']">
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>



    