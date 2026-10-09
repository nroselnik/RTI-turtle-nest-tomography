# RTI Turtle Nest Tomography

Scilab code for reconstructing two-dimensional radio tomographic imaging (RTI) images of buried sea-turtle clutches from received signal strength (RSS) measurements.

The code accompanies the manuscript *Radio tomographic imaging with low-cost wireless nodes for non-destructive detection of buried sea-turtle eggs* (Azmi, Boo, Rahiman, Kishkinev, Rusli and Rosely, in preparation). It was used to produce the tomograms in that study.

## Credits

- **Tomographic imaging method and sensitivity maps:** Assoc. Prof. Ir. Dr. Mohd Hafiz Fazalul Rahiman, Faculty of Electrical Engineering Technology, Universiti Malaysia Perlis (UniMAP). The reconstruction approach and the node sensitivity maps (`e1_wood_te.csv` to `e8_wood_te.csv`) come from his tomography work. Please credit him and cite the paper above when you use this code.
- **Scilab implementation and processing SOP:** Boo Yu Wen, School of Biological Sciences, Universiti Sains Malaysia (USM).
- **Project lead:** Assoc. Prof. Dr. Nik Fadzly N Rosely, USM (nfadzly@usm.my).

## How it works

Eight node positions surround the nest cross-section. For each measured link between nodes *a* and *b*, the normalized loss is

    y_ab = (RSS_ref - RSS_meas) / |RSS_ref| x 100

where `RSS_ref` is the RSS (dBm) of a same-site empty-nest reference and `RSS_meas` is the RSS of the nest being tested. A positive value means the link was attenuated.

Each node has a precomputed sensitivity map `E_k` on a 500 x 500 pixel grid. The circular region of interest has a radius of 225 pixels. The script back-projects each link loss through the product of its two nodes' maps, `E_a x E_b`, and divides by the summed weights of all 28 node pairs (linear back-projection). Finally, each image is rescaled to the range 0 to 1.

**Note:** because each image is rescaled on its own, colour shows where attenuation is concentrated within one cross-section. It cannot be used to compare attenuation strength between images. Use the RSS values for that.

## Requirements

- Windows (the scripts build file paths with `\`)
- Scilab 2026.0.1. The `.bat` launchers expect it at `C:\Program Files\scilab-2026.0.1`. If yours is elsewhere, edit the `SCILAB_DIR` line in the `.bat` file.
- Microsoft Excel, or any spreadsheet program, to prepare the input matrices

## Repository contents

| Path | What it is |
|---|---|
| `RTI_v2.sce` | Main reconstruction script, with Refresh, Contour and Mesh buttons. Use this one. |
| `RTI.sce` | Earlier version, with a Refresh button only |
| `Run_RTI_v2.bat`, `Run_RTI.bat` | Double-click launchers that open Scilab and run the script |
| `CSV files/e1_wood_te.csv` to `e8_wood_te.csv` | Node sensitivity maps (500 x 500). Required. |
| `CSV files/data.csv` | Example 8 x 8 input matrix, loaded when the script starts |
| `Experiment Data/RSSI Calculation - USM.xlsx` | Template that converts reference and measured RSS into normalized loss |
| `Experiment Data/Eggs (nest 2 and 3) - *.csv` | Example inputs from the Chagar Hutang field sampling (2 May 2026) at 10, 30 and 40 cm |

## Input format

Each input file is an 8 x 8 comma-separated matrix of normalized loss values. Rows and columns are nodes N1 to N8, and the transmitter is on the rows.

- The diagonal is `NaN`.
- Links that were not measured are `0`.
- The matrix is symmetric. The script reads only the upper triangle (`i < j`).
- The study measured four opposing through-paths: N1 to N5, N2 to N6, N3 to N7 and N4 to N8.

Example (`Eggs (nest 2) - 30cm.csv`):

    NaN,0,0,0,45.16129032,0,0,0
    0,NaN,0,0,0,39.68253968,0,0
    0,0,NaN,0,0,0,44.26229508,0
    0,0,0,NaN,0,0,0,40.98360656
    45.16129032,0,0,0,NaN,0,0,0
    0,39.68253968,0,0,0,NaN,0,0
    0,0,44.26229508,0,0,0,NaN,0
    0,0,0,40.98360656,0,0,0,NaN

## Step-by-step use

Adapted from the SOP written by Boo Yu Wen.

**A. Prepare the normalized-loss files**

1. Open `Experiment Data/RSSI Calculation - USM.xlsx`.
2. Copy the template (Reference RSSI Matrix, Measured RSSI Matrix and Attenuation) into a new sheet.
3. Enter your RSS values in dBm.
   - Reference: the empty-nest measurement from the same site and depth.
   - Measured: the nest condition being tested.
4. The Attenuation block (normalized loss) updates automatically.
5. Copy each Attenuation block into a new file and save it as `.csv`, in the 8 x 8 format above. Use a clear name, for example `Eggs (nest 2) - 30cm.csv`.
6. Save all the files in the `Experiment Data` folder.

**B. Reconstruct the tomograms**

1. Double-click `Run_RTI_v2.bat`. Scilab opens and runs `RTI_v2.sce`.
2. When asked, select the `CSV files` folder, which holds the sensitivity maps and `data.csv`, and click OK. The example in `data.csv` is drawn first.
3. Click the blue **Refresh** button.
4. Open the `Experiment Data` folder and select the file you want to reconstruct.
5. The tomogram is drawn. Click **Contour** or **Mesh** for other views.
6. Repeat steps 3 to 5 for each file.

## Notes

- `RTI.sce` flips the sensitivity maps vertically when loading them. `RTI_v2.sce` does not; a comment in the code says the maps should not be flipped. Use `RTI_v2.sce` for consistent orientation.
- An empty nest compared with itself gives an all-zero matrix, which cannot be rescaled. The script will show a warning.

## Citation

If you use this code, please cite the accompanying paper (details will be added on publication) and credit Assoc. Prof. Ir. Dr. Mohd Hafiz Fazalul Rahiman (UniMAP) for the tomographic imaging method.

## Licence

This repository is released under the [Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). You may reuse and adapt it, including commercially, provided you give appropriate credit as described above.
