---
marp : true
theme : gaia
class : invert
---
# Final Project  
<style>
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Alice">

p, ul,li {
  font-family: 'Alice', serif;
}

</style>

Slides

https://www.icloud.com/keynote/035IBM-K2cGiC3KwusnviqjMg#Presentation

---
Thanks to 

https://opengameart.org/content/tank-sprite

https://opengameart.org/content/98-pixel-art-rpg-icons

https://opengameart.org/content/animated-coins

https://opengameart.org/content/32x32-stone-brick-sprite

https://opengameart.org/content/stone-tiles-0

---
## Stages
Stages are in keynotes. 

We wrote stages document to 
* organize our thoughts 
* core ideas of our design.

---
## Bullet : holes and array

For bullet we can support up to `bullet_num`'s elements in `bullet_array`. 

* An element in `bullet_array` holds basic information about the bullet. 

```sv
bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | 
((tank_x[i] + (tank_width >> 1)) << 9)  | 
((tank_y[i] + (tank_height >> 1)) << 19));
```
* This is initialization of the element if bullets start appearting on screen.
---
## Bullet : holes and array

* A hole is just an element that doesn't exist. 
* It's a bullet that's not shot by any tanks.
* They are candidates to bullets to be drawn on screen
* So each time we just look at the array, find a hole, and occupy **one of the hole**.
* Since we can only draw one per shot, we need to use if-else to implement holes and array.

---
## Bullet : holes and array
Changes need to be made if you want to customize your bullet number

* Bullet number is called `ARRAY_SIZE` in `tank.sv`.
* Not only should you change that, you also need to modify some hard coded code snippets shown in following slides.
* A hole is found through `always_ff` meaning they'll be checked every frame. If no holes are available, we set `hole_ind` to `tank_num * ARRAY_SIZE` because it's zero-indexed.
---
## Bullet : holes and array

We use `for` loop to remove redundancy as much as we can, although our synthesis tool supports `for` loop poorly. 

```sv
  for(i = 0; i < tank_num; i++) begin // for each tank
    tank_x[i] <= next_tank_x[i];
    tank_y[i] <= next_tank_y[i];
    base_direction[i] <= next_base_direction[i];
    turret_direction[i] <= next_turret_direction[i];
    if(1 == (fire_scc[i] & (fire_scc_num - 1)) ) fire[i] <= 0; // reset in the first frame
    else fire[i] <= next_fire[i];
    ... 
```
This is an example on how to make transition of each tank.



---

```sv
// tank.sv (module tank_position_direction)
if(fire[i] && !(fire_scc[i] & (fire_scc_num - 1)) ) begin
	if(!(bullet_array[i][0] & 1)) 
		hole_ind[i] <= 0;
	else if(!(bullet_array[i][1] & 1)) 
		hole_ind[i] <= 1;
	else if(!(bullet_array[i][2] & 1)) 
		hole_ind[i] <= 2;
	else if(!(bullet_array[i][3] & 1)) 
		hole_ind[i] <= 3;
	else if(!(bullet_array[i][4] & 1)) 
		hole_ind[i] <= 4;
	else if(!(bullet_array[i][5] & 1)) 
		hole_ind[i] <= 5;
	else if(!(bullet_array[i][6] & 1)) 
		hole_ind[i] <= 6;
	else if(!(bullet_array[i][7] & 1)) 
		hole_ind[i] <= 7;
	else
		hole_ind[i] <= ARRAY_SIZE;
end else 
	hole_ind[i] <= ARRAY_SIZE;
```
---

```sv module color_mapper
// color_mapper.sv
  if(ball_on[0][0]) ball_ind = 0;
  else if(ball_on[0][1]) ball_ind = 1;
  else if(ball_on[0][2]) ball_ind = 2;
  else if(ball_on[0][3]) ball_ind = 3;
  else if(ball_on[0][4]) ball_ind = 4;
  else if(ball_on[0][5]) ball_ind = 5;
  else if(ball_on[0][6]) ball_ind = 6;
  else if(ball_on[0][7]) ball_ind = 7;
  else 
  ...
  // do the same for tank 1, 2, ..., tank_num - 1
  else ball_ind = tank_num * ARRAY_SIZE;
```

---

## SCC : Slow Clock Counter

We use SCC to slow down the slock:

* SCC will reset the variable in the second cycle.

* Whenever there is an event, variable will inherit preivous value.

* When SCC reaches the first cycle, we now trigger the event effect.

---

## Attributes

Alive Time

* Realized as a counter
  * Intially when there is a hole we set counter to 1.
  * if the counter goes to 0 (just overflowed), we reset valid bit to make it a hole so that it won't be drawn.
  * If the counter is $1$ to $2^{10}$(because counter is `logic[9:0]`), we advance counter by 1

---
### Alive Time

Here is a basic implementation

```sv
for(idx[i] = 0; idx[i] < ARRAY_SIZE; idx[i]++) // if not a hole, and it exists, update it
  // we've already cleared next_bullet_array when current bullet doesn't exist
	if(idx[i] != hole_ind[i]) begin 
		if((bullet_array[i][idx[i]] & 1) && alive_bullet_cnt[i][idx[i]]) begin
			bullet_array[i][idx[i]] <= next_bullet_array[i][idx[i]];	
			alive_bullet_cnt[i][idx[i]] <= alive_bullet_cnt[i][idx[i]] + 1;
		end else begin 
			alive_bullet_cnt[i][idx[i]] <= 0;
			bullet_array[i][idx[i]] <= 0;
		end
	end
	else begin
		// initialize bullet & alive_cnt: code in previous section
	end
```

---
