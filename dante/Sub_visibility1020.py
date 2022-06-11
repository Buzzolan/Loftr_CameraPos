# -*- coding: utf-8 -*-
"""
Created on Sat Jun 11 10:23:31 2022

@author: tomma
"""
list_array=[]
def Convert(string):
    li = list(string.split(" "))
    list_row=[]
    for number in li:
         element=  float(number)
         list_row.append(element)
         
    list_array.append(list_row)
    return li

with open('VisibilityRef1020.txt') as f:
    
    lines = f.readlines()[2:]
    for x in lines:
        print("numero: ",x) 
        riga=Convert(x)
        print(riga)
       
f.close() 

#scalo i miei valori fx=0.2, fy=0.2

Sub_list=[]
for value in list_array:
    value[0]=format(value[0], '.1f')  
    value[1]=format(0.2*value[1], '.3f')
    value[2]=format(0.2*value[2], '.3f')
  
    Sub_list.append(value)
     



with open("testoutput.txt", "w") as txt_file:
    for line in Sub_list:
        print(line)
        for number in line:
            print("number:", number)
            txt_file.write(number+" ")
            
        
        txt_file.write("\n") # works with any number of elements i
        























