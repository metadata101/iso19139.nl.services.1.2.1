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
  xmlns:java="java:org.fao.geonet.util.XslUtil"
  xmlns:atom="http://www.w3.org/2005/Atom" 
  xmlns:georss="http://www.georss.org/georss" 
  xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
  xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  
  version="2.0"
  exclude-result-prefixes="#all">

  <xsl:import href="process-utility.xsl"/>
  
  <!-- i18n information -->
  <xsl:variable name="inspire-info-loc">
    <msg id="a" xml:lang="eng">INSPIRE Atom service </msg>
    <msg id="b" xml:lang="eng"> is described in online resource section. Run this process to add operations information</msg>
    <msg id="a" xml:lang="dut">Dataset koppelingen overnemen uit de INSPIRE Atom Feed </msg>
    <msg id="b" xml:lang="dut">. Let op: bestaande operaties en dataset koppelingen in de metadata worden overschreven met de waarden uit de atom feed. Bestaande operaties en dataset koppelingen worden verwijderd als dataset-links in de service feed niet juist geidentificeerd worden.</msg>
    <msg id="a" xml:lang="fre">Le service INSPIRE Atom </msg>
    <msg id="b" xml:lang="fre"> est décrit dans la section resource en ligne. Exécuter cette action pour ajouter ou remplacer les informations relatives aux opérations</msg>
  </xsl:variable>

  <!-- Process parameters and variables-->

  <xsl:param name="wxsServiceUrl"/>
  
  <xsl:variable name="wxsOnlineNodes"
    select="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine//gmd:CI_OnlineResource[(
    contains(gmd:protocol/gco:CharacterString, 'INSPIRE Atom')
    ) and gmd:linkage/gmd:URL = $wxsServiceUrl]"/>
  <xsl:variable name="wxsProtocol" select="$wxsOnlineNodes/gmd:protocol/gco:CharacterString"/>
  
  <xsl:variable name="alreadyContainsOp" select="count(//srv:containsOperations[
      srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL=$wxsServiceUrl])"/>
  
  <xsl:variable name="InspireDoc">
    <xsl:if test="$wxsOnlineNodes">
      
           <xsl:copy-of
      select="java:getUrl($wxsServiceUrl)"/>
    </xsl:if>
  </xsl:variable>

  <xsl:template name="list-add-service-info-from-inspire">
    <suggestion process="add-service-info-from-inspire"/>
  </xsl:template>

  <!-- Analyze the metadata record and return available suggestion
    for that process -->
  <xsl:template name="analyze-add-service-info-from-inspire">

    <xsl:param name="root"/>
    
    <xsl:variable name="srv"
      select="$root//*[local-name(.)='SV_ServiceIdentification' or contains(@gco:isoType, 'SV_ServiceIdentification')]"/>
    
    <xsl:variable name="onlineResources"
      select="$root//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[
        contains(gmd:protocol/gco:CharacterString, 'INSPIRE Atom') 
           and normalize-space(gmd:linkage/gmd:URL)!='']"/>

    <xsl:if test="$srv"><!-- Only apply to service metadata--> 
      <xsl:for-each select="$onlineResources">
        <suggestion process="add-service-info-from-inspire" id="{generate-id()}-service" category="onlineSrc" target="srv:containsOperations">
          <name><xsl:value-of select="geonet:i18n($inspire-info-loc, 'a', $guiLang)"/><xsl:value-of select="./gmd:linkage/gmd:URL"
          /><xsl:value-of select="geonet:i18n($inspire-info-loc, 'b', $guiLang)"/>.</name>
          <operational>true</operational>
          <params>{ setAndReplaceOperations:{type:'boolean', defaultValue:'true'},
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



    <xsl:for-each select="$InspireDoc//atom:entry">
      <!-- <entry>
    <title xml:lang="nl">Stads- en Dorpsgezichten</title>
  <inspire_dls:spatial_dataset_identifier_code>e39bd6e0-7651-11e0-a1f0-0800200c9a62</inspire_dls:spatial_dataset_identifier_code>
  <inspire_dls:spatial_dataset_identifier_namespace>http://www.cultureelerfgoed.nl</inspire_dls:spatial_dataset_identifier_namespace>
  <link href="http://www.nationaalgeoregister.nl/geonetwork/srv/nl/csw?Service=CSW&amp;Request=GetRecordById&amp;Version=2.0.2&amp;id=4e2ef670-cddd-11dd-ad8b-0800200c9a66&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;elementSetName=full"
  rel="describedby" type="application/xml" />
  <link rel="alternate" href="http://services.rce.geovoorziening.nl/www/download/data/Stads_en_Dorpsgezichten_nl.xml" type="application/atom+xml" hreflang="nl" title="Feed bevattende de Stads- en Dorpsgezichten dataset" />
  <link rel="alternate" href="http://services.rce.geovoorziening.nl/www/download/data/Stads_en_Dorpsgezichten_nl.xml" type="text/html" hreflang="nl" title="Feed bevattende de Stads- en Dorpsgezichten dataset" />
    <id>http://services.rce.geovoorziening.nl/www/download/data/Stads_en_Dorpsgezichten_nl.xml</id>
    <rights>Geen beperking</rights>
    <updated>2012-06-25T10:45:03</updated>
    <summary>
Deze dataset bevat de begrenzingen van alle gebieden waarvoor de procedure is gestart om het gebied aan te wijzen als rijksbeschermd stads- of dorpsgezicht (ex artikel 35 van de Monumentenwet 1988).    
</summary>
    <georss:polygon>50.74 3.25 53.48 3.25 53.48 7.22 50.74 7.22 50.74 3.25</georss:polygon>
    <category term="http://www.opengis.net/def/crs/EPSG/0/28992" label="Amersfoort / RD New" />
    <category term="http://www.opengis.net/def/crs/EPSG/0/4258" label="ETRS89" />
  </entry> -->

        <xsl:variable name="Identifier" select="inspire_dls:spatial_dataset_identifier_code"></xsl:variable>
        <xsl:variable name="Authority" select="inspire_dls:spatial_dataset_identifier_namespace"></xsl:variable>

   <!--<xsl:message><xsl:value-of select="position()"/>/
   <xsl:value-of select="$Identifier"/>/
   <xsl:value-of select="$Authority"/></xsl:message> -->    
     
        <xsl:variable name="mdName" select="atom:title"/>
        <xsl:variable name="mdTitle" select="atom:title"/>

        <xsl:if test="$mdName!=''">
          <srv:coupledResource>
            <srv:SV_CoupledResource>
              <srv:operationName>
                <gco:CharacterString>GetDataset</gco:CharacterString>
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
        select="srv:couplingType"/>
      <xsl:copy-of
        select="srv:containsOperations"/>
      
  

    <xsl:for-each select="$InspireDoc//atom:entry">
      <!-- todo: wfs inspire featuretype -->
        
        <xsl:variable name="mdName" 
          select="atom:title"/>
          <xsl:variable name="mdTitle" 
          select="atom:title"/>
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
         
        <xsl:variable name="Identifier" select="inspire_dls:spatial_dataset_identifier_code"/>
        <xsl:variable name="Authority" select="inspire_dls:spatial_dataset_identifier_namespace"/>
        <xsl:variable name="mdURL" select="atom:link[@rel='describedby'][1]/@href"/>
        
        
        <!-- create operatesOnelement -->
        <xsl:if test="$mdURL or $Identifier">
        <srv:operatesOn xlink:href="{$mdURL}" uuidref="{$Identifier}"/>
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



    