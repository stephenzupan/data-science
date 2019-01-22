import pandas as pd
from tkinter.filedialog import askopenfilename
import matplotlib.pyplot as plt

# access desired excel sheet, define data frame to be used
filename = askopenfilename()
df = pd.read_excel(io=filename)

# syntax of accessing this data frame: df.iloc[ROW NUMBER][COLUMN NAME]
print_spec_hi = df.iloc[0]['print_spec_hi']
print_spec_low = df.iloc[0]['print_spec_low']
target_spec_hi = df.iloc[0]['tar_spec_hi']
target_spec_low = df.iloc[0]['tar_spec_low']

# create empty lists to hold values
top = []
bottom = []

# insert values into lists
for x in range(0, len(df)):
    top.append(df.iloc[x]['top'])
    bottom.append((df.iloc[x]['bottom']))

# init count variables to be displayed, values dictionary (the lists as key:value pairs)
target_count = 0
print_count = 0
scrap_count = 0
values_dict = dict(zip(top, bottom))

for x, y in values_dict.items():
    if x < target_spec_hi and y > target_spec_low:
        target_count += 1
    elif (x > target_spec_hi and x < print_spec_hi) and (y < target_spec_low and y > print_spec_low):
        scrap_count += 1
    else:
        print_count += 1

# plot values as pie chart
labels = 'target_parts', 'print_parts', 'scrap'
parts = [target_count, print_count, scrap_count]

plt.pie(parts, labels=labels, autopct='%1.1f%%', startangle=90)
plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
plt.legend(loc='best')

# save figure
# supported formats: eps, jpeg, jpg, pdf, pgf, png, ps, raw, rgba, svg, svgz, tif, tiff
filename = filename.replace('.xlsx', '')
plt.savefig('%s visualization' % filename, format='pdf')
