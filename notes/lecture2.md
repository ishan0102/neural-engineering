# Lecture 2: Peripheral Nervous System
- the central nervous system contains the brain and spinal cord (extension of the brain) while the **peripheral nervous system** is used to control muscles

## Muscle Reinnervation
- **muscle reinnervation** involves amputation to connect nerves to healthy muscle
- we can dissect other nerves and transferring them to restore motor abilities
	- logistically you just need a long enough nerve to make the connection
- a common principle is *use it or lose it* which means synapses that are used more frequently grow stronger (habits)
- patients doing reinnervation are told to attempt to make movements regularly to rebuild the neurons and prevent loss of synapses
- if you have a robotic arm and "move" it, you'll feel as though you're really moving it since you restrengthen the input -> output sequence nerves

## Operation
- patients can have multiple degrees of freedom even with robotics since nerve function correlates to intended function
	- this means you don't have to do things sequentially (i.e. open 1 finger at a time), you can just grab something intuitively
- control is linear
- **EMG control** uses myoelectrode interface that sits on top of the skin and measures muscle contractions -> can be used to control prosthetics
- **EMB recognition** shows accurate contour plots that demonstrate contractions

## Sensory Feedback
- when patients are in control after their muscle reinnervation process, they have a similar skin sensation as they used to

### Cyberhand
- direct nerve interface
- less signal range but more afferent stimulation (feedback)

### Longitudinal IntraFascicular Electrodes (LIFEs)
- **LIFEs** were implanted in median nerve in eight long-term amputees within healthy part of a nerve along with 4-8 electrodes
- tried to map stimulus magnitude (electrode current) with sensation magnitude (how much the patient felt sensation)
	- nearly impossible to create a 1:1 mapping, it changes constantly
	- even inserting an electrode causes the brain to reorganize itself, so impedance changes over time -> electrical properties of the system change
- another issue is that this experiment is open-loop (no feedback)

### Closed-Loop Sensory Feedback
- sensors decode muscle activation -> motor commands are measured -> feedback passed back to brain
	- subjects eyes are closed to avoid providing any other feedback
	- performance was very stable
- subjects were found to adjust muscle activations in experiments to make corrections to feedback (asked to grip lightly and gripped too hard -> softened grip)
	- stimulation current was used to innervate muscles and give tactile feedback
- basically, as you're gripping say an object, instead of just getting to see how much it's being squeezed visually you get tactile feedback directly which has been proven to give patients more granular control

## Peripheral Nervous System (PNS) Control
- display a hand grip movie to patients and record signals
- spikes extracted from denoised signals
- desired hand grip is identified by a classifier and executed by robotic hand
- cortical reorganization occurs when an implant is added -> plasticity is useful but we need to be careful to induce good plasticity