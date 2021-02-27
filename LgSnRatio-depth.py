import matplotlib.pyplot as plt

depth = []
lgsn_ratio = []
ff = open('0-40-5-6.txt','r')
lines = ff.readlines()

for i in lines:
	depth.append(i.split()[1])
	lgsn_ratio.append(i.split()[2])

for i in range(len(depth)):
	depth[i] = float(depth[i])
	lgsn_ratio[i] = float(lgsn_ratio[i])
	
#plotting
plt.scatter(depth,lgsn_ratio)
plt.xlabel('Depth (km)')
#plt.set_xlim([0,10000])
plt.title('IK-0-40km-Mw5-6')
plt.ylabel('Lg/Sn Ratio (Vector Amplitude)')
#plt.axhline(y=1.0, color='r', linestyle='-',linewidth=2)
#plt.axhline(y=2.0, color='green', linestyle='-',linewidth=2)
#plt.legend(loc="upper right")
plt.style.use('ggplot')
#axes = plt.gca()
#axes.set_xlim([0,7000])
#axes.set_ylim([0,10])
plt.show()

