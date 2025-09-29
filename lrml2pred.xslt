<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:lrml="http://docs.oasis-open.org/legalruleml/ns/v1.0/"
	xmlns:ruleml="http://ruleml.org/spec">
	<xsl:output method="text"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="ruleml:Rule">
		<xsl:text>rule_base.add(pred("defeasible",atom("</xsl:text>
		<xsl:value-of select="../@key"/>
		<xsl:text>"),pred("</xsl:text>
		<xsl:if test="./ruleml:then/ruleml:Neg">
			<xsl:text>neg_</xsl:text>
		</xsl:if>
		<xsl:value-of select="./ruleml:then//ruleml:Rel"/>
		<xsl:text>",</xsl:text>
		<xsl:call-template name="variables">
			<xsl:with-param name="atom" select=".//ruleml:then//ruleml:Atom"/>
		</xsl:call-template>
		<xsl:text>),</xsl:text>
		<xsl:choose>
			<xsl:when test="count(.//ruleml:if//ruleml:Atom)>1">
				<xsl:text>list(</xsl:text>
					<xsl:for-each select=".//ruleml:if//ruleml:Atom">
						<xsl:call-template name="atom2pred">
							<xsl:with-param name="atom" select=".//ruleml:then//ruleml:Atom"/>
						</xsl:call-template>
						<xsl:if test="position()!=last()">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:for-each>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="atom2pred">
					<xsl:with-param name="atom" select=".//ruleml:if//ruleml:Atom"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>));&#10;</xsl:text>
		<xsl:if test="./ruleml:then/ruleml:Neg">
			<xsl:text>rule_base.add(pred("negation",</xsl:text>
			<xsl:call-template name="atom2pred">
				<xsl:with-param name="atom" select=".//ruleml:then//ruleml:Atom"/>
			</xsl:call-template>
			<xsl:text>,pred("neg_</xsl:text>
			<xsl:value-of select="./ruleml:then//ruleml:Rel"/>
			<xsl:text>",</xsl:text>
			<xsl:call-template name="variables">
				<xsl:with-param name="atom" select=".//ruleml:then//ruleml:Atom"/>
			</xsl:call-template>
			<xsl:text>)));&#10;</xsl:text>
			<xsl:text>rule_base.add(pred("negation",pred("neg_</xsl:text>
			<xsl:value-of select="./ruleml:then//ruleml:Rel"/>
			<xsl:text>",</xsl:text>
			<xsl:call-template name="variables">
				<xsl:with-param name="atom" select=".//ruleml:then//ruleml:Atom"/>
			</xsl:call-template>
			<xsl:text>),</xsl:text>
			<xsl:call-template name="atom2pred">
				<xsl:with-param name="atom" select=".//ruleml:then//ruleml:Atom"/>
			</xsl:call-template>
			<xsl:text>));</xsl:text>
		</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<xsl:template name="variables">
		<xsl:param name="atom"/>
		<xsl:for-each select="$atom//ruleml:Var">
			<xsl:text>Var("</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>")</xsl:text>
			<xsl:if test="position()!=last()">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="atom2pred">
		<xsl:param name="atom"/>
		<xsl:text>pred("</xsl:text>
		<xsl:value-of select="$atom//ruleml:Rel"/>
		<xsl:text>",</xsl:text>
		<xsl:call-template name="variables">
			<xsl:with-param name="atom" select="$atom"/>
		</xsl:call-template>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="lrml:Override">
		<xsl:text>rule_base.add(pred("sup",atom("</xsl:text>
		<xsl:value-of select="substring(@over,2)"/>
		<xsl:text>"),atom("</xsl:text>
		<xsl:value-of select="substring(@under,2)"/>
		<xsl:text>")));&#10;&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="ruleml:then">
		<xsl:text>atom("</xsl:text>
		<xsl:value-of select=".//ruleml:Rel"/>
		<xsl:text>")</xsl:text>
		<xsl:value-of select=".//ruleml:Var"/>
		<xsl:text>)")"</xsl:text>
	</xsl:template>
	
	<xsl:template match="ruleml:if">
		<xsl:for-each select="ruleml:if//ruleml:Atom">
			<xsl:value-of select="ruleml:Rel"/>
				<xsl:call-template name="provera">
					<xsl:with-param name="predikat" select="ruleml:Rel/text()"/>
				</xsl:call-template>
			<xsl:text>(</xsl:text>
			<xsl:for-each select="ruleml:Var | ruleml:Data">
				<xsl:value-of select="."/>
				<xsl:if test="position()!=last()">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
			<xsl:if test="position()!=last()">
				<xsl:text>,</xsl:text>
			</xsl:if>	
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>


