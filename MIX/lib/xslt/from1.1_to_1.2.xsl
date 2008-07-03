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
// Description : from1.1_to1.2.xsl
// XSL transform to go from V1.1 version to V1.2 version of the Schema
// Author : SPIRIT Schema Working Group - Christophe Amerijckx
// Date:     February 2006
-->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:spirit="http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.1">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
            	<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<!-- Changing element spirit:resetValue to spirit:reset with a subelement spirit:value -->

<xsl:template match="*/spirit:register/spirit:resetValue">
	<xsl:element name="spirit:reset">
		<xsl:element name="spirit:value"><xsl:value-of select="."/></xsl:element>
	</xsl:element>
</xsl:template>

<!-- Changing element spirit:hwModel to spirit:model -->

<xsl:template match="spirit:hwModel">
	<xsl:element name="spirit:model">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- Changing element spirit:hwParameters to spirit:modelParameters -->

<xsl:template match="*/spirit:hwParameters">
	<xsl:element name="spirit:modelParameters">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- Changing element spirit:hwParameter to spirit:modelParameter -->

<xsl:template match="*/spirit:hwParameter">
	<xsl:element name="spirit:modelParameter">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- Splitting interconnection attributes into activeInterfaces -->

<xsl:template match="*/spirit:interconnection">
	<xsl:element name="spirit:interconnection">
		<xsl:element name="spirit:activeInterface">
			<xsl:attribute name="spirit:componentRef"><xsl:value-of select="@spirit:component1Ref"/></xsl:attribute>
			<xsl:attribute name="spirit:busRef"><xsl:value-of select="@spirit:busInterface1Ref"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="spirit:activeInterface">
			<xsl:attribute name="spirit:componentRef"><xsl:value-of select="@spirit:component2Ref"/></xsl:attribute>
			<xsl:attribute name="spirit:busRef"><xsl:value-of select="@spirit:busInterface2Ref"/></xsl:attribute>
		</xsl:element>
	</xsl:element>
</xsl:template>

<!-- Add :: to envIdentifier -->

<xsl:template match="spirit:component/spirit:hwModel/spirit:views/spirit:view/spirit:envIdentifier">
    <xsl:element name="spirit:envIdentifier">:<xsl:value-of select="."/>:</xsl:element>
</xsl:template>

<!-- Removing spirit:component/spirit:interconnections -->

<xsl:template match="spirit:component/spirit:interconnections">
</xsl:template>

<!-- Removing spirit:component/spirit:componentInstances -->

<xsl:template match="spirit:component/spirit:componentInstances">
</xsl:template>

<!-- Removing spirit:component/spirit:busInterfaces/spirit:businterface/spirit:exportedInterface -->

<xsl:template match="spirit:component/spirit:busInterfaces/spirit:businterface/spirit:exportedInterface">
</xsl:template>

<!-- Changing spirit:swFunction to spirit:function -->

<xsl:template match="*/spirit:swFunction">
	<xsl:element name="spirit:function">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- putting spirit: before log, decode, pow and containsToken in dependencies -->

<xsl:template match="@spirit:dependency">
	<xsl:attribute name="spirit:dependency">
		<xsl:value-of select="replace(replace(replace(replace(.,'pow','spirit:pow'),'containsToken','spirit:containsToken'),'decode','spirit:decode'),'log','spirit:log')"/>
	</xsl:attribute>
</xsl:template>

<!-- remove default signal strength in a bus definition -->

<xsl:template match="spirit:busDefinition/spirit:signals/spirit:signal/spirit:defaultValue/spirit:strength">
</xsl:template>

<!-- Adding name to channel with generated ID -->

<xsl:template match="spirit:channel">
	<xsl:element name="spirit:channel">
		<xsl:apply-templates select="@*"/>
		<xsl:element name="spirit:name">
			<xsl:text>InternalID</xsl:text><xsl:value-of select="generate-id(.)"/>
		</xsl:element>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- Adding version to design if not existing -->

<xsl:template match="spirit:design">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:choose>
			<xsl:when test="not(spirit:version)">
				<xsl:apply-templates select="spirit:vendor|spirit:library|spirit:name"/>
				<xsl:element name="spirit:version">
					<xsl:text>unset</xsl:text>
				</xsl:element>
				<xsl:apply-templates select="spirit:componentInstances|spirit:interconnections|spirit:adHocConnections|spirit:vendorExtensions"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
