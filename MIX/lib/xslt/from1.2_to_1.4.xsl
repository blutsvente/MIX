<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
// Copyright (c) 2005, 2006, 2007 The SPIRIT Consortium.  All rights reserved.
// www.spiritconsortium.org
//
// THIS WORK FORMS PART OF A SPIRIT CONSORTIUM SPECIFICATION.
// USE OF THESE MATERIALS ARE GOVERNED BY
// THE LEGAL TERMS AND CONDITIONS OUTLINED IN THE SPIRIT
// SPECIFICATION DISCLAIMER AVAILABLE FROM
// www.spiritconsortium.org
//
// This source file is provided on an AS IS basis. The SPIRIT Consortium disclaims 
// ANY WARRANTY EXPRESS OR IMPLIED INCLUDING ANY WARRANTY OF
// MERCHANTABILITY AND FITNESS FOR USE FOR A PARTICULAR PURPOSE. 
// The user of the source file shall indemnify and hold The SPIRIT Consortium harmless
// from any damages or liability arising out of the use thereof or the performance or
// implementation or partial implementation of the schema.
  -->
<!--
// Description :  from1.2_to1.4.xsl
// XSL transform to go from V1.2 version to V1.4 version of the Schema
// Author : SPIRIT Schema Working Group - Christophe Amerijckx
// Date:     January 23rd, 2008
-->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:spirit="http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.2">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		 <xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<xsl:template name="insertComment">
	<xsl:param name="number"/>
	<xsl:param name="message"/>
	<xsl:comment>IP-XACT XSLT Warning#<xsl:value-of select="$number"/>: <xsl:value-of select="$message"/></xsl:comment>
</xsl:template>

<!-- renaming spirit:clockDriver to spirit:otherClockDriver inside spirit:otherClockDrivers and adding spirit:clockName attribute on spirit:clockDriver if not existing-->

<xsl:template match="spirit:component/spirit:otherClockDrivers/spirit:clockDriver">
	<xsl:element name="spirit:otherClockDriver">
		<xsl:apply-templates select="@*"/>
		<xsl:if test="not(@spirit:clockName)">
			<xsl:attribute name="spirit:clockName"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:element>	
</xsl:template>

<!-- removing spirit:choiceStyle and spirit:direction attributes from any element -->

<xsl:template match="//@spirit:choiceStyle"/>

<xsl:template match="//@spirit:direction"/>

<!-- removing spirit:fileSet/spirit:logicalName/@spirit:default if its value is not a boolean -->

<xsl:template match="spirit:component/spirit:fileSets/spirit:fileSet/spirit:file/spirit:logicalName/@spirit:default[(.!='0') and (.!='1') and (.!='false') and (.!='true')]"/>

<!-- changing the content of spirit:define inside a spirit:file -->

<xsl:template match="spirit:component/spirit:fileSets/spirit:fileSet/spirit:file/spirit:define">
	<xsl:element name="spirit:define">
		<xsl:element name="spirit:name"><xsl:value-of select="@spirit:name"/></xsl:element>
		<xsl:element name="spirit:value">
			<xsl:apply-templates select="@spirit:resolve"/>
			<xsl:apply-templates select="@spirit:id"/>
			<xsl:apply-templates select="@spirit:dependency"/>
			<xsl:apply-templates select="@spirit:minimum"/>
			<xsl:apply-templates select="@spirit:maximum"/>
			<xsl:apply-templates select="@spirit:rangeType"/>
			<xsl:apply-templates select="@spirit:order"/>
			<xsl:apply-templates select="@spirit:choiceRef"/>
			<xsl:apply-templates select="@spirit:configGroups"/>
			<xsl:apply-templates select="@spirit:format"/>
			<xsl:apply-templates select="@spirit:prompt"/>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:element>
</xsl:template>

<!-- removing all attributes of spirit:name inside spirit:executableImage -->

<xsl:template match="//spirit:executableImage/spirit:name/@spirit:autoConfig | //spirit:executableImage/spirit:name/@spirit:resolve | //spirit:executableImage/spirit:name/@spirit:id | //spirit:executableImage/spirit:name/@spirit:dependency | //spirit:executableImage/spirit:name/@spirit:minimum | //spirit:executableImage/spirit:name/@spirit:maximum | //spirit:executableImage/spirit:name/@spirit:rangeType | //spirit:executableImage/spirit:name/@spirit:order | //spirit:executableImage/spirit:name/@spirit:choiceRef | //spirit:executableImage/spirit:name/@spirit:configGroups | //spirit:executableImage/spirit:name/@spirit:format | //spirit:executableImage/spirit:name/@spirit:prompt"/>

<!-- moving value of spirit:percentOfPeriod one level higher inside spirit:timingConstraint -->

<xsl:template match="//spirit:timingConstraint[spirit:percentOfPeriod]">
	<xsl:element name="spirit:timingConstraint">
		<xsl:apply-templates select="@*"/>
		<xsl:value-of select="./spirit:percentOfPeriod"/>
	</xsl:element>
</xsl:template>

<!-- copy busType to abstractionType -->
<xsl:template match="spirit:busType">
	<xsl:element name="spirit:busType">
		<xsl:apply-templates select="@*"/>
	</xsl:element>
	<xsl:element name="spirit:abstractionType">
		<xsl:apply-templates select="@spirit:vendor"/>	
		<xsl:apply-templates select="@spirit:library"/>	
		<xsl:attribute name="spirit:name"><xsl:value-of select="./@spirit:name"/>_rtl</xsl:attribute>
		<xsl:apply-templates select="@spirit:version"/>	
	</xsl:element>
</xsl:template>

<!-- removing spirit:crossRef attribute -->
<xsl:template match="//@spirit:crossRef"/>

<!-- changing the way modelParameter is described -->

<xsl:template match="spirit:component/spirit:model/spirit:modelParameters/spirit:modelParameter">
	<xsl:element name="spirit:modelParameter">
		<xsl:apply-templates select="@spirit:dataType"/>
		<xsl:apply-templates select="@spirit:usageType"/>
		<xsl:element name="spirit:name"><xsl:value-of select="@spirit:name"/></xsl:element>
		<xsl:element name="spirit:value">
			<xsl:apply-templates select="@spirit:resolve"/>
			<xsl:apply-templates select="@spirit:id"/>
			<xsl:apply-templates select="@spirit:dependency"/>
			<xsl:apply-templates select="@spirit:minimum"/>
			<xsl:apply-templates select="@spirit:maximum"/>
			<xsl:apply-templates select="@spirit:rangeType"/>
			<xsl:apply-templates select="@spirit:order"/>
			<xsl:apply-templates select="@spirit:choiceRef"/>
			<xsl:apply-templates select="@spirit:configGroups"/>
			<xsl:apply-templates select="@spirit:format"/>
			<xsl:apply-templates select="@spirit:prompt"/>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:element>
</xsl:template>

<!-- in a component fileset function, changing the content of spirit:argument -->

<xsl:template match="spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:argument">
	<xsl:element name="spirit:argument">
		<xsl:apply-templates select="@spirit:dataType"/>
		<xsl:element name="spirit:name"><xsl:value-of select="@spirit:name"/></xsl:element>
		<xsl:element name="spirit:value">
			<xsl:apply-templates select="@spirit:resolve"/>
			<xsl:apply-templates select="@spirit:id"/>
			<xsl:apply-templates select="@spirit:dependency"/>
			<xsl:apply-templates select="@spirit:minimum"/>
			<xsl:apply-templates select="@spirit:maximum"/>
			<xsl:apply-templates select="@spirit:rangeType"/>
			<xsl:apply-templates select="@spirit:order"/>
			<xsl:apply-templates select="@spirit:choiceRef"/>
			<xsl:apply-templates select="@spirit:configGroups"/>
			<xsl:apply-templates select="@spirit:format"/>
			<xsl:apply-templates select="@spirit:prompt"/>
			<xsl:value-of select="."/>
		</xsl:element>	
	</xsl:element>
</xsl:template>

<!-- in a component fileset function, removing all attributes on spirit:sourceName -->

<xsl:template match="spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:resolve | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:id | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:dependency | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:minimum | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:maximum | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:rangeType | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:order | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:configGroups | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:format | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:prompt | spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:sourceFile/spirit:sourceName/@spirit:choiceRef"/>

<!-- in a component fileset function, changing spirit:enabled by spirit:disabled and changing content -->

<xsl:template match="spirit:component/spirit:fileSets/spirit:fileSet/spirit:function/spirit:enabled">
	<xsl:element name="spirit:disabled">
		<xsl:apply-templates select="@spirit:format"/>
		<xsl:apply-templates select="@spirit:resolve"/>
		<xsl:apply-templates select="@spirit:id"/>
		<xsl:if test="@spirit:dependency">
			<xsl:attribute name="spirit:dependency">not(<xsl:value-of select="@spirit:dependency"/>)</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@spirit:minimum"/>
		<xsl:apply-templates select="@spirit:maximum"/>
		<xsl:apply-templates select="@spirit:rangeType"/>
		<xsl:apply-templates select="@spirit:order"/>
		<xsl:apply-templates select="@spirit:choiceRef"/>
		<xsl:apply-templates select="@spirit:configGroups"/>
		<xsl:apply-templates select="@spirit:prompt"/>
		<xsl:choose>
			<xsl:when test=".=false()">
				<xsl:text>true</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- add name to localMemoryMap -->
<xsl:template match="spirit:localMemoryMap">
	<xsl:element name="spirit:localMemoryMap">
		<xsl:element name="spirit:name"><xsl:text>default</xsl:text><xsl:value-of select="generate-id(.)"/></xsl:element>
		<xsl:apply-templates select="./*"/>
	</xsl:element>
</xsl:template>

<!-- removing all attributes from spirit:addressBlock/spirit:bitOffset -->

<xsl:template match="//spirit:addressBlock/spirit:bitOffset/@spirit:format | //spirit:addressBlock/spirit:bitOffset/@spirit:resolve | //spirit:addressBlock/spirit:bitOffset/@spirit:id | //spirit:addressBlock/spirit:bitOffset/@spirit:dependency | //spirit:addressBlock/spirit:bitOffset/@spirit:minimum | //spirit:addressBlock/spirit:bitOffset/@spirit:maximum | //spirit:addressBlock/spirit:bitOffset/@spirit:rangeType | //spirit:addressBlock/spirit:bitOffset/@spirit:order | //spirit:addressBlock/spirit:bitOffset/@spirit:choiceRef | //spirit:addressBlock/spirit:bitOffset/@spirit:configGroups | //spirit:addressBlock/spirit:bitOffset/@spirit:prompt"/>

<!-- add name to addressBlock -->
<xsl:template match="spirit:addressBlock">
	<xsl:element name="spirit:addressBlock">
		<xsl:choose>
			<xsl:when test="./@spirit:name">
				<xsl:element name="spirit:name"><xsl:value-of select="./@spirit:name"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:name"><xsl:text>default</xsl:text><xsl:value-of select="generate-id(.)"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="./*"/>
	</xsl:element>	
</xsl:template>

<!-- add name to bank -->
<xsl:template match="spirit:bank">
	<xsl:element name="spirit:bank">
		<xsl:apply-templates select="@*"/>
		<xsl:choose>
			<xsl:when test="./@spirit:name">
				<xsl:element name="spirit:name"><xsl:value-of select="./@spirit:name"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:name"><xsl:text>default</xsl:text><xsl:value-of select="generate-id(.)"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="spirit:baseAddress"/>
		<xsl:apply-templates select="spirit:bitOffset"/>
		<xsl:apply-templates select="spirit:addressBlock"/>
		<xsl:apply-templates select="spirit:bank"/>
		<xsl:apply-templates select="spirit:subspaceMap"/>
		<xsl:apply-templates select="spirit:usage"/>
		<xsl:apply-templates select="spirit:volatile"/>
		<xsl:apply-templates select="spirit:access"/>
		<xsl:apply-templates select="spirit:parameter"/>
		<xsl:apply-templates select="spirit:vendorExtensions"/>  
	</xsl:element>	
</xsl:template>

<!-- add name to subspaceMap -->
<xsl:template match="spirit:subspaceMap">
	<xsl:element name="spirit:subspaceMap">
		<xsl:apply-templates select="@*"/>
		<xsl:choose>
			<xsl:when test="./@spirit:name">
				<xsl:element name="spirit:name"><xsl:value-of select="./@spirit:name"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:name"><xsl:text>default</xsl:text><xsl:value-of select="generate-id(.)"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="./*"/>
	</xsl:element>	
</xsl:template>

<!-- add name to memoryRemap -->
<xsl:template match="spirit:memoryRemap">
	<xsl:element name="spirit:memoryRemap">
		<xsl:apply-templates select="@*"/>
		<xsl:choose>
			<xsl:when test="./@spirit:name">
				<xsl:element name="spirit:name"><xsl:value-of select="./@spirit:name"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:name"><xsl:text>default</xsl:text><xsl:value-of select="generate-id(.)"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="./*"/>
	</xsl:element>	
</xsl:template>

<!-- add name to fileSet -->
<xsl:template match="spirit:fileSet">
	<xsl:element name="spirit:fileSet">
		<xsl:choose>
			<xsl:when test="./@spirit:fileSetId">
				<xsl:element name="spirit:name"><xsl:value-of select="./@spirit:fileSetId"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:name"><xsl:text>default</xsl:text><xsl:value-of select="generate-id(.)"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="./*"/>
	</xsl:element>	
</xsl:template>

<!-- copy the description-->
<xsl:template match="spirit:description" mode="descriptioncopy">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>


<!-- start the copy and insert description element -->
<xsl:template match="spirit:component//spirit:name">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
	<xsl:apply-templates select="../spirit:description" mode="descriptioncopy"/>	
</xsl:template>

<!-- remove description -->
<xsl:template match="spirit:component//spirit:description"/>

<!-- renaming spirit:signals to spirit:ports -->

<xsl:template match="spirit:component/spirit:model/spirit:signals">
	<xsl:if test="spirit:signal">
		<xsl:element name="spirit:ports">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:if>	
</xsl:template>

<!-- in a component, change the signalConstraintSets to constraintSets -->

<xsl:template match="spirit:component/spirit:model/spirit:signals/spirit:signal/spirit:signalConstraintSets">
	<xsl:element name="spirit:constraintSets">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- in a component, change the signalConstraints to constraintSet and add default as the constraintSetId-->

<xsl:template match="spirit:component/spirit:model/spirit:signals/spirit:signal/spirit:signalConstraintSets/spirit:signalConstraints">
	<xsl:element name="spirit:constraintSet">
		<xsl:choose>
		  <xsl:when test="@spirit:constraintSetId != '' and @spirit:constraintSetId != 'default'">
		    <xsl:attribute name="spirit:constraintSetId"><xsl:value-of select="@spirit:constraintSetId"/></xsl:attribute>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:attribute name="spirit:constraintSetId">default</xsl:attribute>
		  </xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- renaming spirit:signal to spirit:port and changing content-->

<xsl:template match="spirit:component/spirit:model/spirit:signals/spirit:signal">
	<xsl:element name="spirit:port">
		<xsl:apply-templates select="spirit:name"/>
		<xsl:element name="spirit:wire">
			<xsl:apply-templates select="spirit:direction"/>
			<xsl:if test="spirit:left">
				<xsl:element name="spirit:vector">
					<xsl:apply-templates select="spirit:left"/>
					<xsl:apply-templates select="spirit:right"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="spirit:defaultValue or spirit:clockDriver or spirit:singleShotDriver">
				<xsl:element name="spirit:driver">
					<xsl:apply-templates select="spirit:defaultValue"/>
					<xsl:apply-templates select="spirit:clockDriver"/>
					<xsl:apply-templates select="spirit:singleShotDriver"/>
				</xsl:element>
			</xsl:if>
			<xsl:apply-templates select="spirit:signalConstraintSets"/>
		</xsl:element>
		<xsl:apply-templates select="spirit:vendorExtensions"/>
	</xsl:element>	
</xsl:template>

<!-- moving the spirit:value inside spirit:defaultValue -->

<xsl:template match="spirit:component/spirit:model/spirit:signals/spirit:signal/spirit:defaultValue">
	<xsl:choose>
		<xsl:when test="(spirit:value='') or (starts-with(spirit:value,'-'))">
			<xsl:element name="spirit:defaultValue">
				<xsl:apply-templates select="spirit:value/@*"/>
				<xsl:text>0</xsl:text>
			</xsl:element>
		</xsl:when>
		<xsl:when test="spirit:value!=''">
			<xsl:element name="spirit:defaultValue">
				<xsl:apply-templates select="spirit:value/@*"/>
				<xsl:value-of select="spirit:value"/>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
</xsl:template>

<!-- if not present, adding opaque=true on a bridge on slave bus interface -->

<xsl:template match="spirit:busInterface/spirit:slave/spirit:bridge[not(@spirit:opaque)]">
	<xsl:element name="spirit:bridge">
		<xsl:apply-templates select="@*"/>
		<xsl:attribute name="spirit:opaque"><xsl:text>true</xsl:text></xsl:attribute>
	</xsl:element>
</xsl:template>

<!-- changing spirit:connection in a spirit:busInterface to spirit:connectionRequired  and changing value accordingly -->

<xsl:template match="spirit:busInterface/spirit:connection">
	<xsl:choose>
		<xsl:when test=".='required'">
			<xsl:element name="spirit:connectionRequired"><xsl:text>true</xsl:text></xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="spirit:connectionRequired"><xsl:text>false</xsl:text></xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- changing attribute name spirit:interfaceType to spirit:interfaceMode in spirit:busInterface/spirit:monitor -->

<xsl:template match="spirit:busInterface/spirit:monitor/@spirit:interfaceType">
	<xsl:attribute name="spirit:interfaceMode"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- renaming spirit:signalMap to spirit:portMap or removing it if empty -->

<xsl:template match="spirit:component/spirit:busInterfaces/spirit:busInterface/spirit:signalMap">
	<xsl:if test="spirit:signalName">
		<xsl:element name="spirit:portMaps">
			<xsl:for-each select="spirit:signalName">
				<xsl:element name="spirit:portMap">
					<xsl:element name="spirit:logicalPort">
						<xsl:element name="spirit:name">
							<xsl:value-of select="spirit:busSignalName"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="spirit:physicalPort">
						<xsl:element name="spirit:name">
							<xsl:value-of select="spirit:componentSignalName"/>
						</xsl:element>
						<xsl:if test="spirit:left">
							<xsl:element name="spirit:vector">
								<xsl:apply-templates select="spirit:left"/>
								<xsl:apply-templates select="spirit:right"/>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>	
	</xsl:if>
</xsl:template>

<!-- renaming attribute spirit:interfaceName on spirit:hierConnection to spirit:interfaceRef -->

<xsl:template match="spirit:design/spirit:hierConnections/spirit:hierConnection/@spirit:interfaceName">
	<xsl:attribute name="spirit:interfaceRef"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- in a design, changing pin reference and its attributes in adHocConnection and moving the spirit:name attribute to a spirit:name sub-element for an adHocConnection and changing export to externalPortReference to the name of the adHocConnection for an adHocConnection -->

<xsl:template match="spirit:design/spirit:adHocConnections/spirit:adHocConnection">
	<xsl:element name="spirit:adHocConnection">
		<xsl:choose>
			<xsl:when test="@spirit:name">
				<xsl:element name="spirit:name"><xsl:value-of select="@spirit:name"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:name"><xsl:value-of select="generate-id(.)"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each select="spirit:pinReference">
			<xsl:element name="spirit:internalPortReference">
				<xsl:apply-templates select="@spirit:componentRef"/>
				<xsl:attribute name="spirit:portRef"><xsl:value-of select="@spirit:signalRef"/></xsl:attribute>
				<xsl:apply-templates select="@spirit:left"/>
				<xsl:apply-templates select="@spirit:right"/>
			</xsl:element>	
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="spirit:export=true()">
				<xsl:element name="spirit:externalPortReference">
					<xsl:attribute name="spirit:portRef"><xsl:value-of select="@spirit:name"/></xsl:attribute>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- in a design, changing elements spirit:componentRef and spirit:interfaceRef to attributes spirit:componentRef and spirit:busRef of element spirit:activeInterface -->

<xsl:template match="spirit:design/spirit:hierConnections/spirit:hierConnection">
	<xsl:element name="spirit:hierConnection">
		<xsl:apply-templates select="@spirit:interfaceName"/>
		<xsl:element name="spirit:activeInterface">
			<xsl:attribute name="spirit:componentRef">
				<xsl:value-of select="spirit:componentRef"/>
			</xsl:attribute>
			<xsl:attribute name="spirit:busRef">
				<xsl:value-of select="spirit:interfaceRef"/>
			</xsl:attribute>
		</xsl:element>
		<xsl:apply-templates select="spirit:vendorExtensions"/>
	</xsl:element>
</xsl:template>

<!-- in a design, add a name to the interconnection -->
<xsl:template match="spirit:design/spirit:interconnections/spirit:interconnection">
	<xsl:element name="spirit:interconnection">
		<xsl:choose>
			<xsl:when test="./spirit:name">
				<xsl:element name="spirit:name"><xsl:value-of select="./spirit:name"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:name"><xsl:text>default</xsl:text><xsl:value-of select="generate-id(.)"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="./spirit:activeInterface"/>
		<xsl:apply-templates select="./spirit:description"/>
	</xsl:element>	
</xsl:template>


<!-- in a generatorChain, replace spirit:fileGeneratorSelector with spirit:generatorChainSelector -->

<xsl:template match="spirit:generatorChain/spirit:fileGeneratorSelector">
	<xsl:element name="spirit:generatorChainSelector">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>	
	</xsl:element>
</xsl:template>

<!-- in a generatorChain, replace spirit:fileName with spirit:generatorChainRef -->

<xsl:template match="spirit:generatorChain/spirit:fileGeneratorSelector/spirit:fileName">
	<xsl:element name="spirit:generatorChainRef">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>	
	</xsl:element>
</xsl:template>

<!-- in a generatorChain, remove any reference to LGI -->

<xsl:template match="spirit:generatorChain/spirit:generator">
	<xsl:element name="spirit:generator">
		<xsl:choose>
			<xsl:when test="spirit:apiType='LGI'">
				<xsl:apply-templates select="spirit:name"/>
				<xsl:element name="spirit:apiType"><xsl:text>none</xsl:text></xsl:element>
				<xsl:element name="spirit:generatorExe"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- Rename remapSignal to remapPort -->
<xsl:template match="spirit:remapStates/spirit:remapState/spirit:remapSignal">
	<xsl:element name="spirit:remapPort">
		<xsl:apply-templates select="@*"/>
		<xsl:if test=". = true()">0x01</xsl:if>
		<xsl:if test=". = false()">0x00</xsl:if>
	</xsl:element>
</xsl:template>

<!-- move name attribute to an element -->
<xsl:template match="spirit:remapState/@spirit:name">
	<xsl:element name="spirit:name"><xsl:value-of select="."/></xsl:element>
</xsl:template>

	
<!-- Rename attribute spirit:id to spirit:portNameRef -->
<xsl:template match="spirit:remapSignal/@spirit:id">
	<xsl:attribute name="spirit:portNameRef"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- Adding a default value for element which are named scaledNonNegativeInteger or scaledInteger -->
<xsl:template match="spirit:remapAddress[.='']">
	<xsl:element name="spirit:remapAddress">
		<xsl:apply-templates select="@*"/>
		<xsl:text>0</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:range[.='']">
	<xsl:element name="spirit:range">
		<xsl:apply-templates select="@*"/>
		<xsl:text>1</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:baseAddress[.='']">
	<xsl:element name="spirit:baseAddress">
		<xsl:apply-templates select="@*"/>
		<xsl:text>0</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:addressOffset[.='']">
	<xsl:element name="spirit:addressOffset">
		<xsl:apply-templates select="@*"/>
		<xsl:text>0</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:mask[.='']">
	<xsl:element name="spirit:mask">
		<xsl:apply-templates select="@*"/>
		<xsl:text>0</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:clockPulseValue[.='']">
	<xsl:element name="spirit:clockPulseValue">
		<xsl:apply-templates select="@*"/>
		<xsl:text>0</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:singleShotValue[.='']">
	<xsl:element name="spirit:singleShotValue">
		<xsl:apply-templates select="@*"/>
		<xsl:text>0</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:value[.='']">
	<xsl:element name="spirit:value">
		<xsl:apply-templates select="@*"/>
		<xsl:text>0</xsl:text>
	</xsl:element>
</xsl:template>

<!-- removing maxMasters and maxSlaves from a channel -->

<xsl:template match="//spirit:channel/spirit:maxMasters">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">1</xsl:with-param>
		<xsl:with-param name="message">Removing element maxMasters from channel</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="//spirit:channel/spirit:maxSlaves">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">2</xsl:with-param>
		<xsl:with-param name="message">Removing element maxSlaves from channel</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:fileSets if empty -->

<xsl:template match="spirit:component/spirit:fileSets[not(spirit:fileSet)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">3</xsl:with-param>
		<xsl:with-param name="message">Removing empty element fileSets</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:fileSetRefGroup in spirit:executableImage if spirit:fileSetRef is empty -->

<xsl:template match="//spirit:executableImage/spirit:fileSetRefGroup[not(spirit:fileSetRef)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">4</xsl:with-param>
		<xsl:with-param name="message">Removing empty element fileSetRefGroup</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<!-- removing spirit:componentConstraintSets -->

<xsl:template match="spirit:component/spirit:componentConstraintSets">
		<xsl:call-template name="insertComment">
		<xsl:with-param name="number">5</xsl:with-param>
		<xsl:with-param name="message">Removing element componentConstraintSets</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- removing spirit:designRuleConstraints from a component -->

<xsl:template match="//spirit:designRuleConstraints">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">6</xsl:with-param>
		<xsl:with-param name="message">Removing element designRuleConstraints</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- removing spirit:cellName from spirit:cellSpecification -->

<xsl:template match="//spirit:driveConstraint[spirit:cellSpecification/spirit:cellName]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">7</xsl:with-param>
		<xsl:with-param name="message">Removing element driveConstraint since it contains spirit:cellSpecification/spirit:cellName</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="//spirit:loadConstraint[spirit:cellSpecification/spirit:cellName]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">8</xsl:with-param>
		<xsl:with-param name="message">Removing element loadConstraint since it contains spirit:cellSpecification/spirit:cellName</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:resistance from spirit:driveConstraint -->

<xsl:template match="//spirit:driveConstraint[spirit:resistance]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">9</xsl:with-param>
		<xsl:with-param name="message">Removing element driveConstraint since it contains spirit:resistance</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:capacitance from spirit:loadConstraint -->

<xsl:template match="//spirit:loadConstraint[spirit:capacitance]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">10</xsl:with-param>
		<xsl:with-param name="message">Removing element loadConstraint since it contains spirit:capacitance</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:delay from spirit:timingConstraint -->

<xsl:template match="//spirit:timingConstraint[spirit:delay]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">11</xsl:with-param>
		<xsl:with-param name="message">Removing element timingConstraint since it contains spirit:delay</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:configurators and spirit:configuratorRef -->

<xsl:template match="spirit:configurators">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">12</xsl:with-param>
		<xsl:with-param name="message">Removing element configurators</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="spirit:configuratorRef">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">13</xsl:with-param>
		<xsl:with-param name="message">Removing element configuratorRef</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:views inside spirit:model if empty -->

<xsl:template match="spirit:component/spirit:model/spirit:views[not(spirit:view)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">14</xsl:with-param>
		<xsl:with-param name="message">Removing empty views element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:modelParameters inside spirit:model if empty -->

<xsl:template match="spirit:component/spirit:model/spirit:modelParameters[not(spirit:modelParameter)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">15</xsl:with-param>
		<xsl:with-param name="message">Removing empty modelParameters element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:vendorExtensions from spirit:model or if empty -->

<xsl:template match="//spirit:vendorExtensions[not(child::*)] | spirit:component/spirit:model/spirit:vendorExtensions">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">16</xsl:with-param>
		<xsl:with-param name="message">Removing vendorExtensions element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- in a component fileset, removing spirit:owner -->

<xsl:template match="spirit:component/spirit:fileSets/spirit:fileSet/spirit:owner">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">17</xsl:with-param>
		<xsl:with-param name="message">Removing owner element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:memoryMaps if empty -->

<xsl:template match="spirit:component/spirit:memoryMaps[not(spirit:memoryMap)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">18</xsl:with-param>
		<xsl:with-param name="message">Removing empty memoryMaps element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:addressSpaces if empty -->

<xsl:template match="spirit:component/spirit:addressSpaces[not(spirit:addressSpace)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">19</xsl:with-param>
		<xsl:with-param name="message">Removing empty addressSpaces element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:busInterfaceParameters from a spirit:busInterface -->

<xsl:template match="spirit:busInterface/spirit:busInterfaceParameters">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">20</xsl:with-param>
		<xsl:with-param name="message">Removing busInterfaceParameters element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:busInterfaces if empty -->

<xsl:template match="spirit:component/spirit:busInterfaces[not(spirit:busInterface)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">21</xsl:with-param>
		<xsl:with-param name="message">Removing empty busInterfaces element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:index from spirit:busInterface -->

<xsl:template match="spirit:component/spirit:busInterfaces/spirit:busInterface/spirit:index">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">22</xsl:with-param>
		<xsl:with-param name="message">Removing index element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:hierConnections if empty -->

<xsl:template match="spirit:design/spirit:hierConnections[not(spirit:hierConnection)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">23</xsl:with-param>
		<xsl:with-param name="message">Removing empty hierConnections element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:adHocConnections if empty -->

<xsl:template match="spirit:design/spirit:adHocConnections[not(spirit:adHocConnection)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">24</xsl:with-param>
		<xsl:with-param name="message">Removing empty adHocConnections element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:export -->

<xsl:template match="spirit:design/spirit:adHocConnections/spirit:adHocConnection/spirit:export">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">25</xsl:with-param>
		<xsl:with-param name="message">Removing export element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- in a design, removing componentInstances if empty -->

<xsl:template match="spirit:design/spirit:componentInstances[not(spirit:componentInstance)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">26</xsl:with-param>
		<xsl:with-param name="message">Removing empty componentInstances element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- in a design componentInstance, renaming spirit:configuration and changing the content organization. Removing autoConfig attributes -->
<!-- Removing spirit:configuration inside spirit:componentInstance if empty -->
<xsl:template match="spirit:design/spirit:componentInstances/spirit:componentInstance/spirit:configuration">
	<xsl:choose>
		<xsl:when  test="spirit:configurableElement">	
			<xsl:element name="spirit:configurableElementValues">
				<xsl:for-each select="spirit:configurableElement">
					<xsl:element name="spirit:configurableElementValue">
						<xsl:attribute name="spirit:referenceId"><xsl:value-of select="@spirit:referenceId"/></xsl:attribute>
						<xsl:value-of select="spirit:configurableElementValue"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="insertComment">
				<xsl:with-param name="number">27</xsl:with-param>
				<xsl:with-param name="message">Removing empty configuration element</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- remove busDefinition/signals,  busDefinition/busDefParameters, busDefinition/choice -->
<xsl:template match="spirit:busDefinition">
	<xsl:element name="spirit:busDefinition">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="spirit:vendor"/>
		<xsl:apply-templates select="spirit:library"/>
		<xsl:apply-templates select="spirit:name"/>
		<xsl:apply-templates select="spirit:version"/>
		<xsl:apply-templates select="spirit:directConnection"/>
		<xsl:choose>
			<xsl:when test="//spirit:isAddress= true()">
				<xsl:element name="spirit:isAddressable"><xsl:text>true</xsl:text></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="spirit:isAddressable"><xsl:text>false</xsl:text></xsl:element>	
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="spirit:extends"/>
		<xsl:apply-templates select="spirit:maxMasters"/>
		<xsl:apply-templates select="spirit:maxSlaves"/>
		<xsl:call-template name="insertComment">
			<xsl:with-param name="number">28</xsl:with-param>
			<xsl:with-param name="message">Removing signals element</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="insertComment">
			<xsl:with-param name="number">29</xsl:with-param>
			<xsl:with-param name="message">Removing choices element</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="insertComment">
			<xsl:with-param name="number">30</xsl:with-param>
			<xsl:with-param name="message">Removing busDefParameters element</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="spirit:signals/spirit:signal/spirit:onSystem/spirit:group">
			<xsl:element name="spirit:systemGroupNames">
				<xsl:for-each select="spirit:signals/spirit:signal/spirit:onSystem[not(spirit:group = (preceding::spirit:onSystem/spirit:group))]">
					<xsl:element name="spirit:systemGroupName">
						<xsl:value-of select="spirit:group"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
		<xsl:apply-templates select="spirit:vendorExtensions"/>
	</xsl:element>
</xsl:template>

<!-- in a component, remove any LGI generator; remove spirit:componentGenerators if empty -->

<xsl:template match="spirit:component/spirit:componentGenerators">
	<xsl:choose>
		<xsl:when test="spirit:componentGenerator[(spirit:apiType!='LGI') and not(spirit:lgiAccessType)]">
			<xsl:element name="spirit:componentGenerators">
				<xsl:for-each select="spirit:componentGenerator">
					<xsl:choose>
						<xsl:when test="(spirit:lgiAccessType) or (spirit:apiType='LGI') or (not(spirit:apiType))">
							<xsl:call-template name="insertComment">
								<xsl:with-param name="number">31</xsl:with-param>
								<xsl:with-param name="message">Removing componentGenerator since it is an LGI generator</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="spirit:componentGenerator">
								<xsl:apply-templates select="@*"/>
								<xsl:apply-templates/>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="insertComment">
				<xsl:with-param name="number">32</xsl:with-param>
				<xsl:with-param name="message">Removing componentGenerators element since it contains only LGI references</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Removing pmdConfiguration from designConfiguration -->

<xsl:template match="spirit:designConfiguration/spirit:pmdConfiguration">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">33</xsl:with-param>
			<xsl:with-param name="message">Removing designConfiguration element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- Removing spirit:dependency from spirit:register -->

<xsl:template match="spirit:register/spirit:dependency">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">34</xsl:with-param>
			<xsl:with-param name="message">Removing dependency element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- group spirit:parameter-->
<xsl:template match="spirit:parameter" mode="paramscopy">
	<xsl:copy>
		<xsl:element name="spirit:name"><xsl:value-of select="@spirit:name"/></xsl:element>
		<xsl:element name="spirit:value">
			<xsl:apply-templates select="@spirit:resolve"/>
			<xsl:apply-templates select="@spirit:id"/>
			<xsl:apply-templates select="@spirit:dependency"/>
			<xsl:apply-templates select="@spirit:minimum"/>
			<xsl:apply-templates select="@spirit:maximum"/>
			<xsl:apply-templates select="@spirit:rangeType"/>
			<xsl:apply-templates select="@spirit:order"/>
			<xsl:apply-templates select="@spirit:choiceRef"/>
			<xsl:apply-templates select="@spirit:configGroups"/>
			<xsl:apply-templates select="@spirit:format"/>
			<xsl:apply-templates select="@spirit:prompt"/>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:copy>
</xsl:template>

<!-- start the copy and insert the parameters element -->
<xsl:template match="spirit:parameter[1]">
	<xsl:choose>
		<xsl:when test="/spirit:generatorChain">
			<xsl:call-template name="insertComment">
				<xsl:with-param name="number">35</xsl:with-param>
				<xsl:with-param name="message">Removing parameter element</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="spirit:parameters">
				<xsl:apply-templates select="../spirit:parameter" mode="paramscopy"/>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- remove rest of the parameters -->
<xsl:template match="spirit:parameter[position() &gt; 1]"/>

<!-- in spirit:designConfiguration/spirit:generatorChainConfiguration, removing spirit:configurableElement -->
<!-- and spirit:generators/spirit:configurableElement -->

<xsl:template match="spirit:designConfiguration/spirit:generatorChainConfiguration">
	<xsl:element name="spirit:generatorChainConfiguration">
		<xsl:apply-templates select="spirit:generatorChainRef"/>
		<xsl:if test="spirit:configurableElement">
			<xsl:call-template name="insertComment">
				<xsl:with-param name="number">36</xsl:with-param>
				<xsl:with-param name="message">Removing configurableElement element</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:for-each select="spirit:generators">
			<xsl:element name="spirit:generators">
				<xsl:apply-templates select="spirit:generatorName"/>
				<xsl:element name="spirit:configurableElementValues">
					<xsl:for-each select="spirit:configurableElement">
						<xsl:element name="spirit:configurableElementValue">
							<xsl:attribute name="spirit:referenceId"><xsl:value-of select="@spirit:referenceId"/></xsl:attribute>
							<xsl:value-of select="spirit:configurableElementValue"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
		</xsl:for-each>
	</xsl:element>
</xsl:template>

<!-- Removing spirit:bitOffset from spirit:addressSpaceRef, spirit:addressBlock, spirit:bank and spirit:subspaceMap -->

<xsl:template match="spirit:addressSpaceRef/spirit:bitOffset | spirit:addressBlock/spirit:bitOffset | spirit:bank/spirit:bitOffset | spirit:subspaceMap/spirit:bitOffset">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">37</xsl:with-param>
			<xsl:with-param name="message">Removing bitOffset element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- Renaming spirit:bitsInLau to spirit:addressUnitBits from spirit:addressSpace and spirit:memoryMap -->

<xsl:template match="spirit:addressSpace/spirit:bitsInLau | spirit:memoryMap/spirit:bitsInLau">
	<xsl:if test=". != 8">
		<xsl:call-template name="insertComment">
			<xsl:with-param name="number">38</xsl:with-param>
			<xsl:with-param name="message">bitsInLau not equal to 8. Bus Interface referring to this addressSpace or MemoryMap may need to be fixed manually</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
	<xsl:element name="spirit:addressUnitBits"><xsl:value-of select="."/></xsl:element>
</xsl:template>

<!-- Removing spirit:endianness from spirit:addressSpace spirit:addressBlock-->

<xsl:template match="spirit:addressSpace/spirit:endianness | spirit:addressBlock/spirit:endianness">
	<xsl:choose>
		<xsl:when test=". = 'little'">
			<xsl:call-template name="insertComment">
				<xsl:with-param name="number">39</xsl:with-param>
				<xsl:with-param name="message">Removing endianness element</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="insertComment">
				<xsl:with-param name="number">40</xsl:with-param>
				<xsl:with-param name="message">Removing endianness element. Since it was not equal to little, the bus interface may have to be fixed manually</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- removing spirit:format="choice" -->

<xsl:template match="@spirit:format[.='choice']"/>

<!-- removing spirit:cpus if empty -->

<xsl:template match="spirit:component/spirit:cpus[not(spirit:cpu)]">
	<xsl:call-template name="insertComment">
		<xsl:with-param name="number">41</xsl:with-param>
		<xsl:with-param name="message">Removing empty cpus element</xsl:with-param>
	</xsl:call-template>
</xsl:template>


</xsl:stylesheet>