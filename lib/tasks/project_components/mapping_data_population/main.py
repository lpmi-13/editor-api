#!/bin/python3
from p5 import *
from regions import get_region_coords
from random import randint

region_list = []
colours = {}

# Put code to run once here
def setup():
  load_data('pop.csv')
  size(991, 768)
  map = load_image('mercator_bw.png')
  image(
      map, # The image to draw
      0, # The x of the top-left corner
      0, # The y of the top-left corner
      width, # The width of the image
      height # The height of the image
      )
  draw_pin(300, 300, color(255, 0, 0))
  draw_data()
# Put code to run every frame here
def draw():
  pass

def draw_pin(x_coord, y_coord, colour):
  no_stroke()
  fill(colour)
  rect(x_coord, y_coord, 10, 10)

def load_data(file_name):
  with open(file_name) as f:
    for line in f:
      info = line.split(',')
      region_dict = {
        'name': info[0],
        'population': info[1],
        'population density': info[2]
      }
      region_list.append(region_dict)

def draw_data():
  for region in region_list:
    region_name = region['name'] # Get the name of the region
    region_coords = get_region_coords(region_name) # Use the name to get coordinates
    region_x = region_coords['x'] # Get the x coordinate
    region_y = region_coords['y'] # Get the y coordinate
    #print(region_name, region_x, region_y)
    region_colour = Color(randint(0,255), randint(0,255), randint(0, 255)) # Set the pin colour
    colours[region_colour] = region
    draw_pin(region_x, region_y, region_colour)
    
# Put code to run when the mouse is pressed here
def mouse_pressed():
  pixel_colour = Color(get(mouse_x, mouse_y))
  if pixel_colour in colours:
    facts = colours[pixel_colour]
    print('Name: ', facts['name'])
    print('Population: ', facts['population'])
    print('Population density', facts['population density'])
  else:
    print('Region not detected')

run()
