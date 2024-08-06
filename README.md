# 📂 Progress Bar Inspired on 5City 4.0 [STANDALONE]
![image](https://github.com/user-attachments/assets/55435aa8-91fc-4ae6-b284-c782d347ee57)

# Usage
```
local success = exports['fc-progress']:progressBar({
     duration = 5000,
     label = 'Drinking water...',
     icon = 'fa-solid fa-arrows-rotate',
     useWhileDead = false,
     canCancel = true,
     disable = {
         car = true,
         move = true,
         combat =true
     },
     anim = {
         dict = 'mp_player_intdrink',
         clip = 'loop_bottle'
     },
     prop = {
         model = `prop_ld_flow_bottle`,
         pos = vec3(0.03, 0.03, 0.02),
         rot = vec3(0.0, 0.0, -1.5)
     },
})

local isActive = exports['fc-progress']:isProgressActive()
```
