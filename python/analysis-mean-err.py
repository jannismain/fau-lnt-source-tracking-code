EXPORT_LATEX = False

import glob
import csv
from os import path

import pandas as pd
import matplotlib
import numpy as np
import matplotlib.pyplot as plt
from matplotlib2tikz import save as _tikz_save
import ipdb

pd.set_option('display.precision', 6,
              'display.width', 300,
              'display.chop_threshold', 0.0001,
              'display.expand_frame_repr', False,
              'display.max_rows', None)

# DATA EXPORT PATHS
# ...data
PATH_ROOT = '../matlab/mainczjs/evaluation/results/'
NAME_DATA_FILES = '*results.txt'
# ...LaTeX
PATH_LATEX_PLOTS = '../latex/data/plots/'
PATH_LATEX_TABLES = '../latex/data/tables/'

lms_red = (204 / 255, 53 / 255, 56 / 255)

EVALUATIONS = ['base', 'em-iterations', 'min-distance', 'reflect-order', 'T60', 'noise', 'wd', 'var-fixed']
PARAMETERS = {'s':         None, 'md': 0.5, 'wd': 1.2, 'T60': 0.0, 'SNR': 0, 'em': None, 'reflect-order': 3,
              'var-fixed': 0, 'var-val': 0.1}

DICT_SUMMARY = {'x1':              'count',  # sample size
                'em':              np.mean,  # em-iterations
                'T60':             np.mean,
                'SNR':             np.mean,
                'md':              np.mean,
                'reflect-order':   np.mean,
                'var-fixed':       np.mean,
                'var-val':         np.mean,
                'err-mean':        np.mean,
                'percent-matched': np.mean}

DEFAULT_LINE_PLOT_ARGS = {'kind':       'line',
                          'marker':     'o',
                          'markersize': 6,
                          'color':      [lms_red, "orange", "black", "darkgrey", "blue", "magenta", "green", "yellow",
                                         "lightgray"]}


def _get_trial_index(t):
	return ["t{}".format(i + 1) for i in range(t)]


def _get_col_name(s, post):
	return sum([("x{}{},y{}{}".format(n, post, n, post)).split(',') for n in range(1, s + 1)], [])


def _get_err_col_name(s):
	return ["err{}".format(n) for n in range(1, s + 1)]


def get_col_names(s):
	return sum([_get_col_name(s, ""), _get_col_name(s, "est"), _get_err_col_name(s)], [])


def is_x1_correct(row):
	if abs(row["x1"] - row["x1est"]) > 0.001:
		if abs(row["y1"] - row["y1est"]) > 0.001:
			return 1
	return 0


def tikz_save(*args, **kwargs):
	"""Wrapper for tikz_save function, that always suppresses additional info output"""
	kwargs['show_info'] = False
	_tikz_save(*args, **kwargs)


def is_matched(x):
	ret = []
	for el in x:
		if str.lower(str(el)) == "nan":
			ret.append(np.NaN)
		elif abs(el) >= 0.1:
			ret.append(0)
		elif el == np.NaN:
			ret.append(np.Nan)
		else:
			ret.append(1)
	return ret


def round_to_two(x):
	ret = []
	for el in x:
		ret.append(round(x, 2))
	return ret


def adjust_y_axis(step_size, digits=0, min=None, ax=None):
	if ~ax:
		plt.axes()
	if ax.get_ylim()[1] < 1:
		ax.set_ylim([0, 1])
	start, end = ax.get_ylim()
	if not min: min = start
	ax.set_yticks(np.arange(min, round(end + step_size, digits), step_size))


def scatter_plot(df, xaxis='n-sources', yaxis='err-mean'):
	x = df[xaxis].values
	y = df[yaxis].values
	means = df.groupby([xaxis]).mean()[yaxis]
	medians = df.groupby([xaxis]).median()[yaxis]
	plt.scatter(x, y, alpha=0.1, c="gray")
	plt.scatter(means.index.values, means.values, alpha=1.0, c=lms_red, marker="o", linewidth="4", label="mean")
	plt.scatter(medians.index.values, medians.values, alpha=1.0, c="black", marker="_", linewidth="2", label="median")
	# plt.xticks(n-sources_range)
	adjust_y_axis(step_size=0.5, digits=2, min=0)
	plt.grid(True, axis='y')
	plt.xlabel("number of sources")
	plt.ylabel("mean localisation error (m)")
	l = plt.legend()
	if EXPORT_LATEX:
		tikz_save(PATH_SCATTER_PLOT, show_info=False)


def style_boxplot(boxplots, fig=None, axes=None):
	if not type(boxplots) == type([]): boxplots = [boxplots]
	if not fig: fig = boxplots[0][0].ax.get_figure()
	if not axes: axes = [boxplots[0][0].ax]
	for bp in boxplots:
		for key in bp[0].lines.keys():
			for item in bp[0].lines[key]:
				if key == "fliers":
					item.set_markerfacecolor("lightgray")
					item.set_markeredgewidth(0)
					item.set_markeredgecolor(lms_red)
					item.set_markersize(7)
				if key == "medians":
					item.set_color(lms_red)
					item.set_linewidth(3)
				if key == "whiskers" or key == "caps":
					item.set_color("gray")
				else:
					item.set_color(lms_red)
	if axes:
		for ax in axes:
			ax.set_title("")
			ax.set_xlabel("number of sources")
			ax.set_ylabel("mean localisation error (m)")
			ax.grid(axis="x")
			ax.set_ylim([0, 2])
			ax.set_yticks(np.arange(0, 2.1, 0.2))
	if fig:
		fig.suptitle('')


def style_line_plot(xlabel, ylabel, grid):
	plt.xlabel(xlabel)
	plt.ylabel(ylabel)
	plt.grid(axis=grid)


def print_summary(df):
	print("DATA FROM: ", set(df["description"].values))
	summary = df.groupby('n-sources').agg(DICT_SUMMARY).rename(columns={'x1': 'n', 'em': 'em-iterations'})
	print(summary.transpose())
	for col in [x for x in PARAMETERS.keys() if x != "s"]:  # Print additional notes for these columns
		warn = False
		if df[col].min() != df[col].max():
			col_values = df.pivot_table("x1", index=[col], columns=["n-sources"], aggfunc="count")
			if col_values.min().min() == col_values.max().max():
				n = col_values.min().min()
			else:
				if (col_values.min(axis=1).values - col_values.max(axis=1)).sum() != 0:
					warn = True
				n = list(col_values.min(axis=1).values)
			print("NOTE: Data contains range of {col} ({values}, n={n})"
			      .format(col=col, values=[str(x) for x in list(col_values.index.values)], n=n))
			if warn:
				print("WARN: Unbalanced n_sources for '{}'. There may be a trial running at the moment!".format(col))
				print(col_values)
	print()  # empty line at the end


def parse_parameters(fname):
	ret = {'s': None, 'md': 0.5, 'wd': 1.2, 'T60': 0.0, 'SNR': 0, 'em': None, 'refl-ord': 3, 'var-fixed': 0,
	       'var-val': 0.1}
	s = 0
	while True:
		i = fname.find("_", s)
		i2 = fname.find("_", i + 1)
		s = i2
		if i < 0 or i2 < 0:
			break
		else:
			fname_slice = fname[i + 1:i2]
			name, value = fname_slice.split("=", 1)
			ret[name] = value
	return ret


def calculate_helpers(df: pd.DataFrame):
	df_helpers = (df.loc[:, "x1":"x7":2] - df.loc[:, "x1est":"x7est":2].values).rename(
		columns={"x{}".format(i): "x{}matched".format(i) for i in range(8)})
	df_helpers = df_helpers.apply(is_matched, axis=1, raw=True)
	df_helpers["total-matched"] = df_helpers.sum(axis=1)
	df_helpers["percent-matched"] = df_helpers["total-matched"] / df["n-sources"].values
	return df_helpers


def matlab2pandas(dirname=EVALUATIONS, filename=NAME_DATA_FILES, save_to=None, summary=True):
	dfs = []
	if type(dirname) != list:
		dirnames = [dirname, ]
	else:
		dirnames = dirname

	for dirname in dirnames:
		files = glob.glob(path.join(PATH_ROOT, dirname, filename))
		dfs = []

		# read data
		for f in files:
			# look at filename
			fname = f.split(sep="/")[-1]
			params = parse_parameters(fname)
			n_sources = int(params["s"])
			# prepare DataFrame
			df = pd.DataFrame(list(csv.reader(open(f, 'r'), delimiter='\t')), dtype=float)
			df.drop(df.columns[[n_sources * 4 + n_sources]], axis=1, inplace=True)  # drops empty column
			df.columns = get_col_names(n_sources)
			df.index = ["t{}".format(i + 1) for i in range(len(df))]
			for key, value in params.items():
				df[key] = np.float(value)
			df["description"] = dirname
			dfs.append(df)
		df = pd.concat(dfs)

		# prep data for analysis
		df.rename(columns={'s': 'n-sources', 'refl-ord': 'reflect-order'}, inplace=True)
		df['SNR'] = df['SNR'].apply(int)
		df['em'] = df['em'].apply(int)
		df['n-sources'] = df['n-sources'].apply(int)
		df["T60"].apply(round, 2)
		df["err-mean"] = df.loc[:, "err1":_get_err_col_name(n_sources)[-1]].mean(axis=1)
		df["err-total"] = df.loc[:, "err1":_get_err_col_name(n_sources)[-1]].sum(axis=1)
		df_helpers = calculate_helpers(df)
		df = pd.concat([df, df_helpers], axis=1)
		if summary:
			print_summary(df)

		if save_to:
			df.to_pickle(save_to + ".pkl")
		dfs.append(df)
	return pd.concat(dfs, ignore_index=True)


dfs = []
for desc in EVALUATIONS:
	dfs.append(matlab2pandas(dirname=desc, save_to=path.join(PATH_ROOT, desc), summary=True))
df = pd.concat(dfs)
# df.pivot_table(values=["err-mean", "percent-matched"], index=["em"], columns=["n-sources"], aggfunc="mean")

print_summary(df)
