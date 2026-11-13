# Whole-genome variant-calling pipeline (Nextflow DSL2)

The Nextflow pipeline I built for my BSc Honours (Stellenbosch University, 2024): paired-end whole-genome sequencing reads in, a joint-called and VQSR-filtered cohort VCF out, following GATK best practices. It ran on the Centre for High Performance Computing (CHPC) PBS cluster.

**Write-up:** <https://devonallies.github.io/DataAnalysisPortfolio/projects/wgs-variant-calling-pipeline/> explains the design, each step, the tools and their citations.

## Steps

`ALIGN` (BWA-MEM) → `SAM_TO_BAM`, `SORT_BAM`, `INDEX_BAM` (SAMtools) → `BQSR` (GATK BaseRecalibrator and ApplyBQSR) → `HAPLOTYPECALLER` (GVCF mode) → `JOINTGENOTYPING` (GenomicsDBImport and GenotypeGVCFs) → `VARIANT_FILTERING` (VQSR for SNPs and indels, merged).

## Layout

```
script.nf                  main workflow: channels and module wiring
nextflow.config            parameters, per-process resources and cluster modules
modules/local/<step>/      one module per step, each with a stub block for dry runs
samplesheet.example.csv    the input format (sampleId, read1, read2)
```

## Running it

1. Copy `samplesheet.example.csv` to `samplesheet.csv` and list your samples and FASTQ paths.
2. In `nextflow.config`, set `params.projectDir`, `params.referenceDir` and the cluster `clusterOptions`. The reference directory needs the reference FASTA (with `.fai` and `.dict`) and the GATK resource bundle files: dbSNP 138, HapMap 3.3, 1000 Genomes Omni 2.5, and Mills and 1000 Genomes gold-standard indels.
3. Test the wiring without data or cluster time:

   ```bash
   nextflow run script.nf -stub
   ```

4. Run it for real, choosing the reference with `--use_sac_ref true|false`.

## About this code

This is the pipeline **as it was used for the project**, published unchanged except that cluster-specific paths, the project allocation code and the cohort name in `nextflow.config` were replaced with placeholders. No sample sheet or data is included.

Known issues in this snapshot, which I'd fix in a new version:

- In `modules/local/align/main.nf`, `ref_to_use` and `output_sam` are defined only in the `stub:` block, not in `script:`.
- `script.nf` passes `sac_reference_ch` to `ALIGN`, but that channel isn't defined.
- FastQC and MultiQC are configured in `nextflow.config`, but run separately rather than as workflow steps.

The write-up's "What I'd do differently" section covers the larger design improvements (duplicate marking, streaming alignment into sorting, containers).
