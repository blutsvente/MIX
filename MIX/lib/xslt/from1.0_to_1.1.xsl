<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
// Description : from1.0_to1.1.xsl
//		 XSL transform to go from V1.0 version to V1.1 version of the Schema
// Author : SPIRIT Schema Working Group - Christophe Amerijckx
// Date:        Mai 2005
//
// Copyright (c) 2004 SPIRIT.  All rights reserved.
// www.spiritconsortium.com
//
// THIS WORK CONTAINS TRADE SECRETS AND PROPRIETARY
// INFORMATION WHICH IS THE PROPERTY OF ANY OF THE CONTRIBUTING
// MEMBERS OF THE SPIRIT CONSORTIUM, AND MAY BE  LICENSED TO
// OTHER MEMBERS OF THE SPIRIT CONSORTIUM SUBJECT TO THE
// TERMS AND CONDITIONS OF THE IP POLICY, WHICH IP POLICY FORMS
// PART OF THE SPIRIT CONSORTIUM AGREEMENT AND THE SPIRIT
// MEMBERSHIP AGREEMENTS
-->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:spirit="http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.0">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
            	<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<!-- changing the header

<xsl:template match="@xsi:schemaLocation">
	<xsl:attribute name="xsi:schemaLocation">
		<xsl:text>http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.0 http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.1/busDefintion.xsd</xsl:text>
	</xsl:attribute>
</xsl:template> -->


<!-- changing attributes to elements inside busInterface/signalMap/signalName in order to make
     it configurable -->
<xsl:template match="spirit:component/spirit:busInterfaces/spirit:busInterface/spirit:signalMap">
	<xsl:element name="spirit:signalMap">
		<xsl:for-each select="spirit:signalName">
			<xsl:element name="spirit:signalName">
				<xsl:element name="spirit:componentSignalName">
					<xsl:value-of select="."/>
				</xsl:element>
				<xsl:element name="spirit:busSignalName">
					<xsl:value-of select="@spirit:busSignal"/>
				</xsl:element>
				<xsl:if test="@spirit:left">
					<xsl:element name="spirit:left">
						<xsl:value-of select="@spirit:left"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="@spirit:right">
					<xsl:element name="spirit:right">
						<xsl:value-of select="@spirit:right"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:for-each>	
	</xsl:element>
</xsl:template>

<!-- removing busGeneratorSelector from generatorChain -->

<xsl:template match="spirit:generatorChain/spirit:busGeneratorSelector"/>

<!-- changing accessType to lgiAccessType inside componentGenerator -->

<xsl:template match="spirit:component/spirit:componentGenerators/spirit:componentGenerator/spirit:accessType">
	<xsl:element name="spirit:lgiAccessType">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates/>	
	</xsl:element>
</xsl:template>

<!-- changing looseGeneratorExe to generatorExe inside componentGenerator -->

<xsl:template match="spirit:component/spirit:componentGenerators/spirit:componentGenerator/spirit:looseGeneratorExe">
	<xsl:element name="spirit:generatorExe">
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

</xsl:stylesheet>