# VisualLTP
Sine grating based visual LTP paradigm 

Requires Psychtoolbox-3 (http://psychtoolbox.org/)

LTP_Baseline.m is used for pre-tetanus and post-tetanus blocks

LTP_Horizontal_Tetanus.m and LTP_Vertical_Tetanus.m are for administering the high-frequency visual stimulation or photic tetanus. Using either horizontal or vertical sine-gratings allows for the testing of specificity of input

This code implements the paradigm as described in: 

Sumner, R. L., McMillan, R., Spriggs, M. J., Campbell, D., Malpas, G., Maxwell, E., . . . Muthukumaraswamy, S. D. (2020). Ketamine Enhances Visual Sensory Evoked Potential Long-term Potentiation in Patients With Major Depressive Disorder. Biological Psychiatry: Cognitive Neuroscience and Neuroimaging 5(1), 45-55. 10.1016/j.bpsc.2019.07.002



TO USE: 

Edit the variables in the % Essential Personalisation % section to ensure the paradigm provides the correct stimulus size and presentation rate for your system. Only edit variables in the other sections if you know what you are doing!

I recommend breakpointing and the stimlus properties yourself (in particular size and presentation rate) after you have personaised the paradigm as these are vital.


For more information see:

Our reveiw:

Sumner, R. L., Spriggs, M. J., Muthukumaraswamy, S. D., & Kirk, I. J. (2020). The role of Hebbian learning in human perception: a methodological and theoretical review of the human Visual Long-Term Potentiation paradigm. Neuroscience & Biobehavioral Reviews, 115, 220-237. https://doi.org/10.1016/j.neubiorev.2020.03.013

First paper on visual LTP in humans: 

Teyler, T. J., Hamm, J. P., Clapp, W. C., Johnson, B. W., Corballis, M. C., & Kirk, I. J. (2005). Long-term potentiation of human visual evoked responses. European Journal of Neuroscience, 21(7), 2045-2050. https://doi.org/10.1111/j.1460-9568.2005.04007.

On specificity of input:

Ross, R. M., McNair, N. A., Fairhall, S. L., Clapp, W. C., Hamm, J. P., Teyler, T. J., & Kirk, I. J. (2008). Induction of orientation-specific LTP-like changes in human visual evoked potentials by rapid sensory stimulation. Brain Research Bulletin, 76(1-2), 97-101. http://doi.org/10.1016/j.brainresbull.2008.01.021
