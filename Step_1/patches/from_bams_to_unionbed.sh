#!/bin/bash
# Vendored from timnat/DifCover with fixes for modern BAM @SQ headers and bedtools CLI.
# - ref.length: upstream awk often writes an empty file (breaks unionbedg -g).
# - genomeCoverageBed / unionBedGraphs → bedtools subcommands (same as Dockerfile sed).

echo "Usage: program sample1.bam sample2.bam"
echo "This program requires BEDTOOLS and SAMTOOLS installed and to be in your PATH!"
echo "The input files must be alignments to the SAME reference genome. Bam files MUST BE coordinate sorted and we suggest (but not required) to filter them with samtools view -F2308 q5 (filter out all unmapped reads, not primary alignments, secondary alignments)."
echo "The output file *.unionbedcv records for each bed interval coverage for sample1 and sample 2 in corresponding columns. Program also generates and store bedcoverage files *.bedcov.Vk1s_sorted for each sample. ATTENTION, this script uses unionBedGraphs (from bedtools) that doesn't accept some symbols like '#', have to replace them in bedcov files and ref.length with ':' ."

if [ "$#" -ne 2 ]; then
  echo "Wrong number of arguments"
  echo "Usage: program sample1.coordinate_sorted_bam_file sample2.coordinate_sorted_bam_file"
  exit 1
fi

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
bam1=$1
bam2=$2

if [ ! -f "$bam1" ]; then
  echo "file $bam1 not found."
  exit 1
fi
if [ ! -f "$bam2" ]; then
  echo "file $bam2 not found."
  exit 1
fi

SECONDS=0
echo " "
echo "sample1 is for $bam1" > Renaming.list
echo "sample2 is for $bam2" >> Renaming.list

echo " "
echo "1.1. Computing coverage for file $bam1 using bedtools: result in sample1.bedcov"
bedtools genomecov -bga -ibam "$bam1" > sample1.bedcov

echo "1.2. Computing coverage for file $bam2 using bedtools: result in sample2.bedcov"
bedtools genomecov -bga -ibam "$bam2" > sample2.bedcov

if [ ! -s sample1.bedcov ] || [ ! -s sample2.bedcov ]; then
  echo "ERROR: bedtools genomecov produced an empty bedgraph for one or both BAMs." >&2
  echo "Check that BAMs are coordinate-sorted, indexed, and contain mapped reads." >&2
  exit 1
fi

echo "2. Calculating length of reference_genome scaffolds from $bam1"

samtools view -H "$bam1" > "$bam1.header"
# Upstream used awk -F'[\t:]' '{print $3"\t"$5}' which is wrong for typical @SQ lines → empty ref.length.
awk '/^@SQ/ {
  sn = ""; ln = ""
  for (i = 1; i <= NF; i++) {
    if ($i ~ /^SN:/) sn = substr($i, 4)
    if ($i ~ /^LN:/) ln = substr($i, 4)
  }
  if (sn != "" && ln ~ /^[0-9]+$/)
    print sn "\t" ln
}' "$bam1.header" > ref.length

if [ ! -s ref.length ]; then
  echo "ERROR: ref.length is empty after parsing BAM header — bedtools unionbedg -g cannot run."
  echo "Check: samtools view -H \"$bam1\" | head -20"
  exit 1
fi

echo "3. Preparing inputs for unionbedg"
# NOTE: DifCover upstream sorts massive bedgraphs with `sort -V`, which is very memory hungry and
# frequently fails on small VMs. For coordinate-sorted BAMs, bedtools genomecov output is already
# ordered by (chrom, start) so we reuse it directly and only sort the small ref.length.
export LC_ALL=C
mv -f sample1.bedcov sample1.bedcov.Vk1s_sorted
mv -f sample2.bedcov sample2.bedcov.Vk1s_sorted
sort -V -k1 -s ref.length > ref.length.Vk1s_sorted

if [ ! -s ref.length.Vk1s_sorted ]; then
  echo "ERROR: ref.length.Vk1s_sorted is empty — cannot run unionbedg." >&2
  exit 1
fi

echo "4. Putting together coverage from two samples in one file"

bedtools unionbedg -header -i sample1.bedcov.Vk1s_sorted sample2.bedcov.Vk1s_sorted -names sample1 sample2 -g ref.length.Vk1s_sorted -empty > sample1_sample2.unionbedcv_draft

awk '{if($3!=4294967295) print $0}' sample1_sample2.unionbedcv_draft > sample1_sample2.unionbedcv_draft1
rm sample1_sample2.unionbedcv_draft

#Check file *unionbedcv if it has e+ numbers, if yes, convert them to decimal

"$SCRIPT_PATH/convert_exp_to_dec_in_unionbed.sh" sample1_sample2.unionbedcv_draft1 > sample1_sample2.unionbedcv

durationall=$SECONDS
echo " OVERALL time to generate *unionbedcv from $bam1 and $bam2 was $(($durationall / 60)) minutes and $(($durationall % 60)) seconds."

rm sample1.bedcov
rm sample2.bedcov
#rm sample1.bedcov.Vk1s_sorted
#rm sample2.bedcov.Vk1s_sorted
rm sample1_sample2.unionbedcv_draft1
rm ref.length
