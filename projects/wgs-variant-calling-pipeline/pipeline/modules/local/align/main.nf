process ALIGN {

	tag "$sampleId"
	publishDir "${params.outdir}/aligned", mode: 'symlink'

	input:
	tuple val(sampleId), path(read1), path(read2)
	path reference_genome
		
	output:
	tuple val(sampleId), path("${sampleId}*.sam"), emit: sam

	script:
	"""
	bwa mem \
	-R "@RG\\tID:${sampleId}\\tSM:${sampleId}\\tLB:lib1\\tPL:MGI\\tPU:unit1" \
	${ref_to_use} \
	${read1} \
	${read2} \
	> "${output_sam}"
	"""

	stub:
	def sac_ref			= params.sac_ref.toBoolean()
	def stub_output_sam	= sac_ref ? "${sampleId}_sac.sam" : "${sampleId}.sam"
	"""
	touch "${stub_output_sam}"
	"""
}
