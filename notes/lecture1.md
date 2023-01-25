# Lecture 1: Introduction

## Neural Engineering
**neural engineering** is understanding how our brain works to engineer applications and therapies
- determining Parkinson's location in brain and using deep brain stimulation
- light activated nerve cells in mice through optogenetics  

we can also develop new techniques to advance our knowledge of the brain and explore neural activity in different ways. we hypothesize that our brain evolved to control our body -> environment -> world.

## Central Nervous System
- **motor cortex** takes voluntary movements and translates them into a sequence of commands
- **spinal cord** takes the commands and executes them electrically with motor neurons
- **somatotopic organization** is the mapping of brain points to parts of the body

### Peripheral Nerves
- lay outside of the central nervous system
- can perform **muscle reinnervation** to replace limbs (e.g. robotic arms), reinnervation is basically supplying nerves to a body part that has lost them

### Spinal Cord
- complex neural circuitry connecting neurons to rest of the body
- **central nervous system** is brain + spinal cord
- say there is a lesion in the spinal cord, the circuitry above and below does not receive activity (input/output). the language of the central nervous system is electricity
	- we could send electrical stimulation to mimic the reaction (e.g. stimulating a leg for a paraplegic by applying the sequence of commands to move a leg up)

### Motor Brain
- has cortical and subcortical areas
- motor brain = motor cortex + a bunch of other stuff like basal ganglia
- **somatotopic organization**: brain space for body functions are not proportional to size, but to importance and level of required control (i.e. hands are more "important" than the back so they get better and larger brain space)
- motor cortex is for movement and somatosensory cortex is for somatic sensation (body's senses)
	- we can apply electrical current during open brain surgery to move someone's legs for example, which is how we are able to map brain tissue to muscles/senses

## Brain Machine Interfaces
- information retrieval from brain signals -> feature extraction thorugh signal transformations -> classification/regression with ML -> action generation via artificial muscles/robots
- neural correlation of movement execution and intention, there is an initial intention signal before the actual action is made so we can use that for inference
- there are also multi-unit recordings but they are invasive (can make a human drink coffee using brain signals)

### Deep Brain Stimulation
- can use high frequency stimulation (HFS) for treatment of movement disorders like Parkinsons
- HFS of subthalamic nucleus improves motor symptoms and reduces needs for meds
- downside: injecting huge amounts of electrical fields that propagate across the body

## Sensory Brain
- auditory system
- visual system
- somatosensory system

### Cochlear Implant
- cochlea uses hairs as sensory cells so hair loss can create loss of hearing since that is where the electrical stimulation occurs
- we can simulate this stimulation of healthy hair cells with electrodes

### Retina Implant
- can use electrodes to simulate retinal cells but both the retina and cochlea cells are dense so it is hard to have the same resolution

### Electronic Skins
- different parts of the body have different tactile and proprioception (sense of moving) based on "importance"
- skin has many mechanoreceptors but the hands have more than the back for obvious reasons
- musculoskeletal system has proprioceptors
- if your proprioceptors don't work you can't tell that you're touching ground, falling, etc. so you're effectively paralyzed

