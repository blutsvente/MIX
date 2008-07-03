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
// Description :  from1.2_to1.4_abstractionDef.xsl
// XSL transform to go from a V1.2 version of a busDefinition to a V1.4 version of an abstractionDefinition
// Author : SPIRIT Schema Working Group - Christophe Amerijckx
// Date:     December 2007
-->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
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
	<xsl:comment>IP-XACT Abstr Def XSLT Warning#<xsl:value-of select="$number"/>: <xsl:value-of select="$message"/></xsl:comment>
</xsl:template>

<!-- changing the schemaLocation attribute if it contains a reference to busDefinition.xsd -->

<xsl:template match="@xsi:schemaLocation">
	<xsl:attribute name="xsi:schemaLocation">
		<xsl:choose>
			<xsl:when test="contains(.,'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.2/busDefinition.xsd')">
				<xsl:variable name="before" select="substring-before(.,'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.2/busDefinition.xsd')"/>
				<xsl:variable name="after" select="substring-after(.,'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.2/busDefinition.xsd')"/>
				<xsl:value-of select="concat($before,'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4/abstractionDefinition.xsd',$after)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<!-- rename to abstractionDef -->
<xsl:template match="spirit:busDefinition">
	<xsl:element name="spirit:abstractionDefinition">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="spirit:vendor"/>
		<xsl:apply-templates select="spirit:library"/>
		<xsl:element name="spirit:name"><xsl:value-of select="spirit:name"/>_rtl</xsl:element>
		<xsl:apply-templates select="spirit:version"/>
		<xsl:element name="spirit:busType">
			<xsl:attribute name="spirit:vendor"><xsl:value-of select="spirit:vendor"/></xsl:attribute>
			<xsl:attribute name="spirit:library"><xsl:value-of select="spirit:library"/></xsl:attribute>
			<xsl:attribute name="spirit:name"><xsl:value-of select="spirit:name"/></xsl:attribute>
			<xsl:attribute name="spirit:version"><xsl:value-of select="spirit:version"/></xsl:attribute>
		</xsl:element>
		<xsl:if test="spirit:extends">
			<xsl:element name="spirit:extends">
				<xsl:attribute name="spirit:vendor"><xsl:value-of select="spirit:extends/@spirit:vendor"/></xsl:attribute>
				<xsl:attribute name="spirit:library"><xsl:value-of select="spirit:extends/@spirit:library"/></xsl:attribute>
				<xsl:attribute name="spirit:name"><xsl:value-of select="spirit:extends/@spirit:name"/>_rtl</xsl:attribute>
				<xsl:attribute name="spirit:version"><xsl:value-of select="spirit:extends/@spirit:version"/></xsl:attribute>
			</xsl:element>
		</xsl:if>
		<xsl:apply-templates select="spirit:signals"/>
		<xsl:apply-templates select="spirit:description"/>
		<xsl:apply-templates select="spirit:vendorExtensions"/>  
	</xsl:element>	
</xsl:template>


<!-- in a bus definition, changing spirit:signals to spirit:ports -->

<xsl:template match="spirit:busDefinition/spirit:signals">
	<xsl:element name="spirit:ports">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>	
	</xsl:element>
</xsl:template>


<!-- in a busdefinition, changing bitWidth to width -->

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal/*/spirit:bitWidth">
	<xsl:element name="spirit:width">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>	
	</xsl:element>
</xsl:template>


<!-- in a bus definition, place the defaultValue inside defaultDriver -->

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal/spirit:defaultValue">
	<xsl:element name="spirit:defaultValue">
		<xsl:choose>
			<xsl:when test="(spirit:value='') or (starts-with(spirit:value,'-'))">
				<xsl:text>0</xsl:text>
			</xsl:when>
			<xsl:otherwise>	
				<xsl:value-of select="spirit:value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- in a bus definition, the direction 'illegal' is moved inside a spirit:presence element; that direction cannot be used anymore -->
<!-- Also moving the spirit:busDefSignalConstraints inside onSystem, onSlave and onMaster elements. Since there were multiple sets now we just have to pick one.  Say the first one -->

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal/spirit:onSystem">
	<xsl:element name="spirit:onSystem">
		<xsl:choose>
			<xsl:when test="spirit:direction='illegal'">
				<xsl:apply-templates select="spirit:group"/>
				<xsl:element name="spirit:presence">illegal</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*"/>
				<xsl:if test="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:timingConstraint or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:designRuleConstraints[1] or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:driveConstraint[1] or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:loadConstraint[1]">
					<xsl:element name="spirit:modeConstraints">
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:timingConstraint"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:designRuleConstraints[1]"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:driveConstraint[1]"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:loadConstraint[1]"/>
					</xsl:element>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal/spirit:onSlave">
	<xsl:element name="spirit:onSlave">
		<xsl:choose>
			<xsl:when test="spirit:direction='illegal'">
				<xsl:element name="spirit:presence">illegal</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*"/>
				<xsl:if test="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:timingConstraint or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:designRuleConstraints[1] or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:driveConstraint[1] or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:loadConstraint[1]">
					<xsl:element name="spirit:modeConstraints">
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:timingConstraint"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:designRuleConstraints[1]"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:driveConstraint[1]"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:loadConstraint[1]"/>
					</xsl:element>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal/spirit:onMaster">
	<xsl:element name="spirit:onMaster">
		<xsl:choose>
			<xsl:when test="spirit:direction='illegal'">
				<xsl:element name="spirit:presence">illegal</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*"/>
				<xsl:if test="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:timingConstraint or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:designRuleConstraints[1] or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:driveConstraint[1] or ../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:loadConstraint[1]">
					<xsl:element name="spirit:modeConstraints">
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:timingConstraint"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:designRuleConstraints[1]"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:driveConstraint[1]"/>
						<xsl:apply-templates select="../spirit:busDefSignalConstraintSets/spirit:busDefSignalConstraints[1]/spirit:loadConstraint[1]"/>
					</xsl:element>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- removing busDefSignalConstraints since it is moved inside onMaster, onSlave and onSystem -->

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal/spirit:busDefSignalConstraintSets"/>

<!-- moving value of spirit:percentOfPeriod one level higher inside spirit:timingConstraint -->

<xsl:template match="//spirit:timingConstraint[spirit:percentOfPeriod]">
	<xsl:element name="spirit:timingConstraint">
		<xsl:apply-templates select="@*"/>
		<xsl:value-of select="./spirit:percentOfPeriod"/>
	</xsl:element>
</xsl:template>

<!-- removing spirit:cellName from spirit:cellSpecification -->

<xsl:template match="//spirit:driveConstraint[spirit:cellSpecification/spirit:cellName]">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">1</xsl:with-param>
			<xsl:with-param name="message">Removing driveConstraint element since it contains a cellName element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="//spirit:loadConstraint[spirit:cellSpecification/spirit:cellName]">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">2</xsl:with-param>
			<xsl:with-param name="message">Removing loadConstraint element since it contains a cellName element</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- removing spirit:designRuleConstraints -->

<xsl:template match="//spirit:designRuleConstraints">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">3</xsl:with-param>
			<xsl:with-param name="message">Removing designRuleConstraints element</xsl:with-param>
	</xsl:call-template>
</xsl:template>	

<!-- removing spirit:delay from spirit:timingConstraint -->

<xsl:template match="//spirit:timingConstraint[spirit:delay]">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">4</xsl:with-param>
			<xsl:with-param name="message">Removing timingConstraint element since it contains a delay element</xsl:with-param>
	</xsl:call-template>
</xsl:template>	

<!-- removing spirit:resistance from spirit:driveConstraint -->

<xsl:template match="//spirit:driveConstraint[spirit:resistance]">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">5</xsl:with-param>
			<xsl:with-param name="message">Removing driveConstraint element since it contains a resistance element</xsl:with-param>
	</xsl:call-template>
</xsl:template>	

<!-- removing spirit:capacitance from spirit:loadConstraint -->

<xsl:template match="//spirit:loadConstraint[spirit:capacitance]">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">6</xsl:with-param>
			<xsl:with-param name="message">Removing loadConstraint element since it contains a capacitance element</xsl:with-param>
	</xsl:call-template>
</xsl:template>	

<!-- removing spirit:vendorExtensions if empty -->

<xsl:template match="//spirit:vendorExtensions[not(child::*)]">
	<xsl:call-template name="insertComment">
			<xsl:with-param name="number">7</xsl:with-param>
			<xsl:with-param name="message">Removing empty vendorExtensions element</xsl:with-param>
	</xsl:call-template>
</xsl:template>	

<!-- in a bus definition, changing spirit:signal to spirit:port and moving spirit:requiresDriver inside spirit:wire-->

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal">
	<xsl:element name="spirit:port">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="spirit:logicalName"/>
		<xsl:element name="spirit:wire">
			<xsl:if test="spirit:isClock or spirit:isReset or spirit:isData or spirit:isAddress">
				<xsl:element name="spirit:qualifier">
					<xsl:apply-templates select="spirit:isAddress"/>
					<xsl:apply-templates select="spirit:isData"/>
					<xsl:apply-templates select="spirit:isClock"/>
					<xsl:apply-templates select="spirit:isReset"/>
				</xsl:element>
			</xsl:if>
			<xsl:apply-templates select="spirit:onSystem"/>	
			<xsl:apply-templates select="spirit:onMaster"/>	
			<xsl:apply-templates select="spirit:onSlave"/>
			<xsl:choose>
				<xsl:when test="spirit:defaultValue">
					<xsl:apply-templates select="spirit:defaultValue"/>
					<xsl:if test="spirit:requiresDriver">
						<xsl:call-template name="insertComment">
							<xsl:with-param name="number">8</xsl:with-param>
							<xsl:with-param name="message">Removing requiresDriver element since defaultValue exists</xsl:with-param>
						</xsl:call-template>	
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="spirit:requiresDriver"/>	
				</xsl:otherwise>
			</xsl:choose>	
			<xsl:apply-templates select="spirit:busDefSignalConstraintSets"/>	
		</xsl:element>
		<xsl:apply-templates select="spirit:vendorExtensions"/>	
	</xsl:element>
</xsl:template>

</xsl:stylesheet>
