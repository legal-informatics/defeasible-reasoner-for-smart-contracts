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
		<!--
		rule_base.add(pred("defeasible",atom("x"),atom("y"),atom("z")));
		
		rule_base.add(pred("defeasible",atom("ruleX_label"),atom("ruleX_then_label"),atom("ruleX_if_label")));
		rule_base.add(pred("fact", atom("ruleX_if_label")), pred("excessive_speed", Var("Defendant")));
		// otherwise, if the predicate excessive_speed(Defendant) is conclusion of an other defeasible rule:
		// excessive_speed(Defendant) :- above_limit(Defendant)
		rule_base.add(pred("defeasible", atom("ruleX_if_label")), pred("excessive_speed", Var("Defendant")));
		
		a:-b,c.			rule_base.add(pred("defeasible",atom("r1"),atom("a"),atom("b"),atom("c")));
		c.				rule_base.add(pred("fact",atom("c")));
		b:-d.			rule_base.add(pred("defeasible",atom("r2"),atom("b"),atom("d")));
		~b:-e.			rule_base.add(pred("defeasible",atom("r3"),atom("neg_b"),atom("e")));
						rule_base.add(pred("negation",atom("b"),atom("neg_b")));
						rule_base.add(pred("negation",atom("neg_b"),atom("b")));
		
		:cc_art246para1i:       committed_art246para1(Defendant):-substance_is_narcotic(Defendant),deed(Defendant,buying)
		:ps_rdlpcs_list1_num54: substance_is_narcotic(Defendant):-substance(Defendant,cocaine)
		if body of some rule contains predicate that is head of some defeasible rule, that predicate is replaced by its label
		similarly for strict rules?
		TODO: try to embed predicate inside predicate, as alternative to the above scenario with labels (to preserve variables)
		:cc_art246para1i: committed_art246para1(Defendant):-defeasibly(ps_rdlpcs_list1_num54_then),deed(Defendant,buying)
		:ps_rdlpcs_list1_num54:    substance_is_narcotic(Defendant):-substance(Defendant,cocaine)
		
		ruleX_label: ruleX_then_part:-ruleX_if_part.
		defeasible("ruleX_label","ruleX_then_part","ruleX_if_part")
		
		ruleX_if_part := pred1(Defendant,...), pred2(Defendant,...), ...
		pred(fact("ruleX_if_part")), pred(...), pred(...), ...
		
		ruleX_then_part :=
		
		r1: guilty(Defendant) :- commited_crime(Defendant), adult(Defendant).
		r2: commited_crime(Defendant) :- murdered(Defendant, Victim).
		r3: ~commited_crime(Defendant) :- self_defence(Defendant).
		r4: r3>r2
		
		defeasible("r1","guilty","r1_if_part")
		  fact("r1_if_part") := defeasibly(commited_crime), commited_crime(Defendant), adult(Defendant)
		defeasible("r2","commited_crime","murdered")
		defeasible("r3","neg_commited_crime","self_defence")
		sup("r3","r2")
		fact("murdered") := murdered(Defendant,Victim)
		fact("self_defence") := self_defence("Defendant")
		// negation("commited_crime","neg_commited_crime").   \\  negation("neg_commited_crime","commited_crime")
		
		<xsl:value-of select="@key"/>
		-->
		<xsl:text>rule_base.add(pred("defeasible",atom("</xsl:text>
		<xsl:value-of select="../@key"/>  <!-- rule name -->
		<xsl:text>"),pred("</xsl:text>
		<xsl:if test="./ruleml:then/ruleml:Neg">
			<xsl:text>neg_</xsl:text>
		</xsl:if>
		<xsl:value-of select="./ruleml:then//ruleml:Rel"/>    <!-- head -->
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
	
	<!-- -->
	
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

