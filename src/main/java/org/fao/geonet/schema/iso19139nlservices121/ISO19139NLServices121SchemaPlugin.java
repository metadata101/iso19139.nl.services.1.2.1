/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.schema.iso19139nlservices121;

import java.util.*;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.kernel.schema.AssociatedResource;
import org.fao.geonet.kernel.schema.AssociatedResourcesSchemaPlugin;
import org.fao.geonet.kernel.schema.ExportablePlugin;
import org.fao.geonet.kernel.schema.ISOPlugin;
import org.fao.geonet.kernel.schema.MultilingualSchemaPlugin;
import org.fao.geonet.schema.iso19139.ISO19139Namespaces;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.xpath.XPath;

import com.google.common.base.Splitter;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * Created by francois on 6/15/14.
 */
public class ISO19139NLServices121SchemaPlugin
        extends org.fao.geonet.kernel.schema.SchemaPlugin
        implements
                AssociatedResourcesSchemaPlugin,
                MultilingualSchemaPlugin,
                ExportablePlugin,
                ISOPlugin {
    public static final String IDENTIFIER = "iso19139.nl.services1.2.1";

    private static ImmutableSet<Namespace> allNamespaces;
    private static Map<String, Namespace> allTypenames;
    private static Map<String, String> allExportFormats;

    static {
        allNamespaces = ImmutableSet.<Namespace>builder()
                .add(ISO19139Namespaces.GCO)
                .add(ISO19139Namespaces.GMD)
                .add(ISO19139Namespaces.SRV)
                .build();
        allTypenames = ImmutableMap.<String, Namespace>builder()
                .put("csw:Record", Namespace.getNamespace("csw", "http://www.opengis.net/cat/csw/2.0.2"))
                .put("gmd:MD_Metadata", ISO19139Namespaces.GMD)
                .put("dcat", Namespace.getNamespace("dcat", "http://www.w3.org/ns/dcat#"))
                .build();

        allExportFormats = ImmutableMap.<String, String>builder()
                // This is more for all basic iso19139 profiles using this bean as default
                // The conversion is not available in regular iso19139 plugin.
                // This is for backward compatibility.
                .put("convert/to19139.xsl", "metadata-iso19139.xml")
                .build();
    }

    public ISO19139NLServices121SchemaPlugin() {
        super(IDENTIFIER, allNamespaces);
    }


    /**
     * Return sibling relation defined in aggregationInfo.
     *
     * @param metadata
     * @return
     */
    public Set<AssociatedResource> getAssociatedResourcesUUIDs(Element metadata) {

        String XPATH_FOR_AGGRGATIONINFO = "*//gmd:aggregationInfo/*" +
                "[gmd:aggregateDataSetIdentifier/*/gmd:code " +
                "and gmd:associationType/gmd:DS_AssociationTypeCode/@codeListValue!='']";
        Set<AssociatedResource> listOfResources = new HashSet<AssociatedResource>();
        List<?> sibs = null;
        try {
            sibs = Xml.selectNodes(
                            metadata,
                            XPATH_FOR_AGGRGATIONINFO,
                            allNamespaces.asList());


            for (Object o : sibs) {
                try {
                    if (o instanceof Element) {
                        Element sib = (Element) o;
                        Element agId = (Element) sib.getChild("aggregateDataSetIdentifier", ISO19139Namespaces.GMD)
                                .getChildren().get(0);
                        String sibUuid = getChild(agId, "code", ISO19139Namespaces.GMD)
                                .getChildText("CharacterString", ISO19139Namespaces.GCO);
                        final Element associationTypeEl = getChild(sib, "associationType", ISO19139Namespaces.GMD);
                        String associationType = getChild(associationTypeEl, "DS_AssociationTypeCode", ISO19139Namespaces.GMD)
                                .getAttributeValue("codeListValue");
                        final Element initiativeTypeEl = getChild(sib, "initiativeType", ISO19139Namespaces.GMD);
                        String initiativeType = "";
                        if (initiativeTypeEl != null) {
                            initiativeType = getChild(initiativeTypeEl, "DS_InitiativeTypeCode", ISO19139Namespaces.GMD)
                                    .getAttributeValue("codeListValue");
                        }
                        AssociatedResource resource = new AssociatedResource(sibUuid, initiativeType, associationType);
                        listOfResources.add(resource);
                    }
                } catch (Exception e) {
                    Log.error(Log.JEEVES, "Error getting resources UUIDs", e);
                }
            }
        } catch (Exception e) {
            Log.error(Log.JEEVES, "Error getting resources UUIDs", e);
        }
        return listOfResources;
    }

    private Element getChild(Element el, String name, Namespace namespace) {
        final Element child = el.getChild(name, namespace);
        if (child == null) {
            return new Element(name, namespace);
        }
        return child;
    }

    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
        ElementFilter elementFilter = new ElementFilter("parentIdentifier", ISO19139Namespaces.GMD);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                "CharacterString", ISO19139Namespaces.GCO,
                null);
    }

    public Set<String> getAssociatedDatasetUUIDs(Element metadata) {
        // Dutch metadata stores in uuidref the gmd:code of the dataset and in xlink:href the link to the CSW GetRecordById
        Set<String> datasetLinks = getAttributeXlinkhrefValues(metadata, "operatesOn",ISO19139Namespaces.SRV);
        //datasetLinks = getAttributeUuidrefValues(metadata, "operatesOn", ISO19139NLServices121Namespaces.SRV);
        //datasetLinks = getAttributeXlinkhrefValues(metadata, "operatesOn", ISO19139NLServices121Namespaces.SRV);
        Set<String> uuids = new HashSet<String>();

        for(String link: datasetLinks) {
            String[] links = link.toLowerCase().split("\\?");
            if (links.length>1){
                String query = links[1];
                final Map<String, String> map = Splitter.on('&').trimResults().withKeyValueSeparator("=").split(query);
                String uuid = map.get("id");
                if (StringUtils.isNotEmpty(uuid)) {
                    uuids.add(uuid);
                }
            }
        }

        return uuids;
    }

    public Set<String> getAssociatedFeatureCatalogueUUIDs(Element metadata) {
        return getAttributeUuidrefValues(metadata, "featureCatalogueCitation", ISO19139Namespaces.GMD);
    }

    public Set<String> getAssociatedSourceUUIDs(Element metadata) {
        return getAttributeUuidrefValues(metadata, "source", ISO19139Namespaces.GMD);
    }

    private Set<String> getAttributeUuidrefValues(Element metadata, String tagName, Namespace namespace) {
        ElementFilter elementFilter = new ElementFilter(tagName, namespace);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                "uuidref");
    }

    private Set<String> getAttributeXlinkhrefValues(Element metadata, String tagName, Namespace namespace) {
        ElementFilter elementFilter = new ElementFilter(tagName, namespace);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                "href",
            ISO19139Namespaces.XLINK
                );
    }

    @Override
    public List<Element> getTranslationForElement(Element element, String languageIdentifier) {
        final String path = ".//gmd:LocalisedCharacterString" +
                "[@locale='#" + languageIdentifier + "']";
        try {
            XPath xpath = XPath.newInstance(path);
            @SuppressWarnings("unchecked")
            List<Element> matches = xpath.selectNodes(element);
            return matches;
        } catch (Exception e) {
            Log.debug(LOGGER_NAME, getIdentifier() + ": getTranslationForElement failed " +
                    "on element " + Xml.getString(element) +
                    " using XPath '" + path +
                    "updatedLocalizedTextElement exception " + e.getMessage());
        }
        return null;
    }

    /**
     *  Add a LocalisedCharacterString to an element. In ISO19139, the translation are
     *  stored gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString.
     *
     * <pre>
     * <gmd:title xsi:type="gmd:PT_FreeText_PropertyType">
     *    <gco:CharacterString>Template for Vector data in ISO19139 (multilingual)</gco:CharacterString>
     *    <gmd:PT_FreeText>
     *        <gmd:textGroup>
     *            <gmd:LocalisedCharacterString locale="#FRE">Modèle de données vectorielles en ISO19139 (multilingue)</gmd:LocalisedCharacterString>
     *        </gmd:textGroup>
     * </pre>
     *
     * @param element
     * @param languageIdentifier
     * @param value
     */
    @Override
    public void addTranslationToElement(Element element, String languageIdentifier, String value) {
        // An ISO19139 element containing translation has an xsi:type attribute
        element.setAttribute("type", "gmd:PT_FreeText_PropertyType",
                Namespace.getNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance"));

        // Create a new translation for the language
        Element langElem = new Element("LocalisedCharacterString", ISO19139Namespaces.GMD);
        langElem.setAttribute("locale", "#" + languageIdentifier);
        langElem.setText(value);
        Element textGroupElement = new Element("textGroup", ISO19139Namespaces.GMD);
        textGroupElement.addContent(langElem);

        // Get the PT_FreeText node where to insert the translation into
        Element freeTextElement = element.getChild("PT_FreeText", ISO19139Namespaces.GMD);
        if (freeTextElement == null) {
            freeTextElement = new Element("PT_FreeText", ISO19139Namespaces.GMD);
            element.addContent(freeTextElement);
        }
        freeTextElement.addContent(textGroupElement);
    }

    /**
     * Remove all multingual aspect of an element. Keep the md language localized strings
     * as default gco:CharacterString for the element.
     *
     * @param element
     * @param mdLang Metadata lang encoded as #EN
     * @return
     * @throws JDOMException
     */
    @Override

    public Element removeTranslationFromElement(Element element, List<String> langs) throws JDOMException {
        String mainLanguage = langs != null && langs.size() > 0 ? langs.get(0) : "#EN";

        List<Element> nodesWithStrings = (List<Element>) Xml.selectNodes(element, "*//gmd:PT_FreeText", Arrays.asList(ISO19139Namespaces.GMD));

        for(Element e : nodesWithStrings) {
            // Retrieve or create the main language element
            Element mainCharacterString = ((Element)e.getParent()).getChild("CharacterString", ISO19139Namespaces.GCO);
            if (mainCharacterString == null) {
                // create it if it does not exist
                mainCharacterString = new Element("CharacterString", ISO19139Namespaces.GCO);
                ((Element)e.getParent()).addContent(0, mainCharacterString);
            }

            // Retrieve the main language value if exist
            List<Element> mainLangElement = (List<Element>) Xml.selectNodes(
                e,
                "*//gmd:LocalisedCharacterString[@locale='" + mainLanguage + "']",
                Arrays.asList(ISO19139Namespaces.GMD));

            // Set the main language value
            if (mainLangElement.size() == 1) {
                String mainLangString = mainLangElement.get(0).getText();

                if (StringUtils.isNotEmpty(mainLangString)) {
                    mainCharacterString.setText(mainLangString);
                } else if (mainCharacterString.getAttribute("nilReason", ISO19139Namespaces.GCO) == null){
                    ((Element)mainCharacterString.getParent()).setAttribute("nilReason", "missing", ISO19139Namespaces.GCO);
                }
            } else if (StringUtils.isEmpty(mainCharacterString.getText())) {
                ((Element)mainCharacterString.getParent()).setAttribute("nilReason", "missing", ISO19139Namespaces.GCO);
            }
        }

        // Remove unused lang entries
        List<Element> translationNodes = (List<Element>)Xml.selectNodes(element, "*//node()[@locale]");
        for(Element el : translationNodes) {
            // Remove all translations if there is no or only one language requested
            if(langs.size() <= 1 ||
                !langs.contains(el.getAttribute("locale").getValue())) {
                Element parent = (Element)el.getParent();
                parent.detach();
            }
        }

        // Remove PT_FreeText which might be emptied by above processing
        for(Element el : nodesWithStrings) {
            if (el.getChildren().size() == 0) {
                el.detach();
            }
        }

        return element;
    }

    @Override
    public String getBasicTypeCharacterStringName() {
        return "gco:CharacterString";
    }

    @Override
    public Element createBasicTypeCharacterString() {
        return new Element("CharacterString", ISO19139Namespaces.GCO);
    }

    @Override
    public Map<String, Namespace> getCswTypeNames() {
        return allTypenames;
    }

    @Override
    public Map<String, String> getExportFormats() {
        return allExportFormats;
    }

    @Override
    public Element addOperatesOn(Element serviceRecord,
                                 Map<String, String> layers,
                                 String serviceType,
                                 String baseUrl) {

        Element root = serviceRecord
            .getChild("identificationInfo", ISO19139Namespaces.GMD)
            .getChild("SV_ServiceIdentification", ISO19139Namespaces.SRV);

        if (root != null) {

            // Coupling type MUST be present as it is the insertion point
            // for coupledResource
            Element couplingType = root.getChild("couplingType", ISO19139Namespaces.SRV);
            int coupledResourceIdx = root.indexOf(couplingType);

            layers.keySet().forEach(uuid -> {
                String layerName = layers.get(uuid);

                // Create coupled resources elements to register all layername
                // in service metadata. This information could be used to add
                // interactive map button when viewing service metadata.
                Element coupledResource = new Element("coupledResource", ISO19139Namespaces.SRV);
                coupledResource.setAttribute("nilReason", "synchronizedFromOGC", ISO19139Namespaces.GCO);
                Element scr = new Element("SV_CoupledResource", ISO19139Namespaces.SRV);


                // Create operation according to service type
                Element operation = new Element("operationName", ISO19139Namespaces.SRV);
                Element operationValue = new Element("CharacterString", ISO19139Namespaces.GCO);

                if (serviceType.startsWith("WMS"))
                    operationValue.setText("GetMap");
                else if (serviceType.startsWith("WFS"))
                    operationValue.setText("GetFeature");
                else if (serviceType.startsWith("WCS"))
                    operationValue.setText("GetCoverage");
                else if (serviceType.startsWith("SOS"))
                    operationValue.setText("GetObservation");
                operation.addContent(operationValue);

                // Create identifier (which is the metadata identifier)
                Element id = new Element("identifier", ISO19139Namespaces.SRV);
                Element idValue = new Element("CharacterString", ISO19139Namespaces.GCO);
                idValue.setText(uuid);
                id.addContent(idValue);

                // Create scoped name element as defined in CSW 2.0.2 ISO profil
                // specification to link service metadata to a layer in a service.
                Element scopedName = new Element("ScopedName", ISO19139Namespaces.GCO);
                scopedName.setText(layerName);

                scr.addContent(operation);
                scr.addContent(id);
                scr.addContent(scopedName);
                coupledResource.addContent(scr);

                // Add coupled resource before coupling type element
                if (coupledResourceIdx != -1) {
                    root.addContent(coupledResourceIdx, coupledResource);
                }


                // Add operatesOn element at the end of identification section.
                Element op = new Element("operatesOn", ISO19139Namespaces.SRV);
                op.setAttribute("nilReason", "synchronizedFromOGC", ISO19139Namespaces.GCO);
                op.setAttribute("uuidref", uuid);

                String hRefLink = baseUrl + "api/records/" + uuid + "/formatters/xml";
                op.setAttribute("href", hRefLink, ISO19139Namespaces.XLINK);

                root.addContent(op);
            });
        }

        return serviceRecord;
    }
    @Override
    public List<Extent> getExtents(Element record) {
        List<Extent> extents = new ArrayList<>();

        ElementFilter bboxFinder = new ElementFilter("EX_GeographicBoundingBox", ISO19139Namespaces.GMD);
        @SuppressWarnings("unchecked")
        Iterator<Element> bboxes = record.getDescendants(bboxFinder);
        while (bboxes.hasNext()) {
            Element box = bboxes.next();
            try {
                extents.add(new Extent(
                    Double.valueOf(box.getChild("westBoundLongitude", ISO19139Namespaces.GMD).getChild("Decimal", ISO19139Namespaces.GCO).getText()),
                    Double.valueOf(box.getChild("eastBoundLongitude", ISO19139Namespaces.GMD).getChild("Decimal", ISO19139Namespaces.GCO).getText()),
                    Double.valueOf(box.getChild("southBoundLatitude", ISO19139Namespaces.GMD).getChild("Decimal", ISO19139Namespaces.GCO).getText()),
                    Double.valueOf(box.getChild("northBoundLatitude", ISO19139Namespaces.GMD).getChild("Decimal", ISO19139Namespaces.GCO).getText())
                ));
            } catch (NullPointerException e) {}
        }
        return extents;
    }
}
