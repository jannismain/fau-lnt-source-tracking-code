import glob
import csv
from os import path

import pandas as pd
import matplotlib
import numpy as np
from decimal import Decimal
import matplotlib.pyplot as plt
from matplotlib.patches import Patch, Rectangle  # for custom legend items
from matplotlib.pyplot import *
from matplotlib2tikz import save as _tikz_save

# DISPLAY CONFIGURATION
BP_OFFSETS = [0,0,0.1,0.15,0.20, 0.25, 0.35]
boxplot_args = {'notch':False,'return_type':'both','widths':0.08,'showmeans':True}
DEFAULT_LINE_PLOT_ARGS = {'kind':'line',
                          'marker':'o',
                          'markersize':6,
                          'color':colors}
matplotlib.style.use('default')


def float_fmt(f: float):
    if f%1==0:
        f = Decimal(f)
        fmt = "{:.0f}"
    elif abs(f)>10000:
        fmt = "{:1.2E}"
    elif abs(f)<0.01:
        fmt = "{:1.2e}"
    elif abs(f)<4:
        fmt = "{:.2f}"
    else:
        fmt = "{:.2f}"
    return fmt.format(f)

pd.set_option('display.precision', 2,
              'display.width', 300,
              'display.chop_threshold', 0.0001,
              'display.expand_frame_repr', True,
              'display.max_rows', 55,
              'max_colwidth', 20,
              'display.float_format', float_fmt)

# DATA EXPORT PATHS
# ...data
PATH_ROOT = '/Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/results/'
NAME_DATA_FILES = '*results.txt'
# ...LaTeX
PATH_LATEX_PLOTS = '/Users/jannismainczyk/latex/plots/boxplots/'
PATH_LATEX_TABLES = '/Users/jannismainczyk/latex/data/tables/'

lms_red = (204/255, 53/255, 56/255)
colors = ['k',lms_red,'orange','xkcd:azure','xkcd:indigo','xkcd:magenta']

EVALUATIONS = ['base', 'em-iterations', 'min-distance', 'reflect-order', 'T60', 'noise', 'wd', 'var-fixed', 'worst-case']
PARAMETERS = {'s':None, 'md':0.5, 'wd':1.2, 'T60':0.0, 'SNR':0, 'em':None, 'reflect-order':3, 'var-fixed':0, 'var-val':0.1}

DICT_SUMMARY = {'x1':'count',  # sample size
                'em':np.mean,  # em-iterations
                'T60':np.mean,
                'SNR':np.mean,
                'md':np.mean,
                'reflect-order':np.mean,
                'var-fixed':np.mean,
                'var-val':np.mean,
                'err-mean':np.mean,
                'percent-matched':np.mean}

# Boxplot constants
YAXIS_LABELS = {'err-mean': 'MAE', 'percent-matched': '''% matched'''}
YAXIS_LIM = {'err-mean': 2.5, 'percent-matched': 1}
YAXIS_STEPS = {'err-mean': 0.5, 'percent-matched': 0.2}


def _get_trial_index(t):
    return ["t{}".format(i+1) for i in range(t)]

def _get_col_name(s,post):
    return sum([("x{}{},y{}{}".format(n,post,n,post)).split(',') for n in range(1,s+1)],[])

def _get_err_col_name(s):
    return ["err{}".format(n) for n in range(1,s+1)]

def get_col_names(s):
    return sum([_get_col_name(s,""), _get_col_name(s,"est"), _get_err_col_name(s)], [])

def is_x1_correct(row):
    if abs(row["x1"]-row["x1est"]) > 0.001:
        if abs(row["y1"]-row["y1est"]) > 0.001:
            return 1
    return 0

def tikz_save(*args, **kwargs):
    """Wrapper for tikz_save function, that always suppresses additional info output"""
    defaults = {'show_info':False,
                'figurewidth':'\\figurewidth',
                'figureheight':'\\figureheight',
                'textsize':6.0}
    for key, val in defaults.items():
        if key not in kwargs: kwargs[key] = val

    _tikz_save(*args, **kwargs)

def is_matched(x):
    ret = []
    for el in x:
        if str.lower(str(el))=="nan":
            ret.append(np.NaN)
        elif abs(el)>=0.1:
            ret.append(0)
        elif el==np.NaN:
            ret.append(np.Nan)
        else:
            ret.append(1)
    return ret

def round_to_two(x):
    ret = []
    for el in x:
        ret.append(round(x, 2))
    return ret

def ticks_restrict_to_integer(axis):
    """Restrict the ticks on the given axis to be at least integer,
    that is no half ticks at 1.5 for example.
    """
    from matplotlib.ticker import MultipleLocator
    major_tick_locs = axis.get_majorticklocs()
    if len(major_tick_locs) < 2 or major_tick_locs[1] - major_tick_locs[0] < 1:
        axis.set_major_locator(MultipleLocator(1))

def init_grid(spgrid: tuple, figsize: tuple):
    plt.subplots(spgrid[0],spgrid[1], figsize=figsize)
    ax = list()
    for i in range(1,spgrid[0]*spgrid[1]+1):
        ax.append(plt.subplot(spgrid[0],spgrid[1],i))
    i=0
    return ax, i

def adjust_y_axis(step_size, digits=0, min=None, max=None, ax=None):
    if isinstance(ax, type(None)):
        plt.axes()
    if ax.get_ylim()[1]<1:
        ax.set_ylim([0,1])
    start, end = ax.get_ylim()
    if not min: min=start
    if not max: max=round(end+step_size, digits)
    ax.set_yticks(np.arange(min, max, step_size))

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

def style_boxplot(boxplots, axes, idx, elements, measure="err-mean"):
    # parse arguments
    if not type(boxplots) == type([]): boxplots = [boxplots]
    if not axes: axes = [boxplots[0][0].ax]
    offset = BP_OFFSETS[elements]
    offset_table = np.linspace(-offset, offset, elements)
    c = colors[idx]
    for bp in boxplots:
        for key, val in bp[0].lines.items():
            for item in val:
                item.set_color(c)
                item.set_linewidth(0.5)
                if key == "fliers":
                    item.set_markerfacecolor(c)
                    item.set_markeredgewidth(0.1)
                    item.set_markeredgecolor(c)
                    item.set_markersize(3)
                    item.set_alpha(0.2)
                if key == "medians":
                    pass
                if key == "means":
                    item.set_marker('x')
                    item.set_markerfacecolor(colors[idx])
                    item.set_markeredgecolor(colors[idx])
        boxlines = bp[0][1]
        for el in boxlines:
            if not el == 'fliers':
                setp(boxlines[el], color=colors[idx], linewidth=1)  # this styles elements not in box
            for el2 in boxlines[el]:
                line = el2
                setp(line, xdata=getp(line, 'xdata') + offset_table[idx])
    axes[0].get_figure().suptitle('')
    for ax in axes:
        ax.set_title('')
        ax.set_xlabel("$S$")
        ax.set_ylabel(YAXIS_LABELS[measure])
        ax.xaxis.grid(False);
        ax.yaxis.grid(True)
        ax.set_xticklabels([2, 3, 4, 5, 6, 7])
        ax.set_ylim([0, YAXIS_LIM[measure]])
        ax.set_yticks(np.arange(0, YAXIS_LIM[measure] + 0.01, YAXIS_STEPS[measure]))
        ax.tick_params(axis='both', which='both', length=0)  # disable all ticks

def load_all_data():
    dfs = []
    for desc in EVALUATIONS:
        dfs.append(matlab2pandas(dirname=desc, save_to=path.join(PATH_ROOT, desc), summary=False))
    try:
        df = pd.concat(dfs)
    except ValueError:
        df = dfs
    return df

def style_line_plot(xlabel, ylabel, grid, ax=None):
    if isinstance(ax, type(None)):
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        plt.grid(axis=grid)
    else:
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)
        ax.grid(axis=grid)

def print_summary(df, verbose=True):
    print("DATA FROM: ", set(df["description"].values))
    summary = df.groupby('n-sources').agg(DICT_SUMMARY).rename(columns={'x1':'n', 'em':'em-iterations'})
    print(summary.transpose())
    for col in [x for x in PARAMETERS.keys() if x != "s"]:  # Print additional notes for these columns
        warn=False
        if df[col].min()!=df[col].max():
            col_values = df.pivot_table("x1", index=[col], columns=["n-sources"], aggfunc="count")
            if col_values.min().min()==col_values.max().max():
                n=col_values.min().min()
            else:
                if (col_values.min(axis=1).values-col_values.max(axis=1)).sum() != 0:
                    warn=True
                n = list(col_values.min(axis=1).values)
            print("NOTE: Data contains range of {col} ({values}, n={n})"
                  .format(col=col, values=[str(x) for x in list(col_values.index.values)], n=n))
            if warn and verbose:
                print("WARN: Unbalanced n_sources for '{}'. There may be a trial running at the moment!".format(col))
                print(col_values)
    print()  # empty line at the end

def parse_parameters(fname):
    ret = {'s':None, 'md':0.5, 'wd':1.2, 'T60':0.0, 'SNR':0, 'em':None, 'refl-ord':3, 'var-fixed':0, 'var-val':0.1}
    done=False
    s=0
    while not done:
        i = fname.find("_", s)
        i2 = fname.find("_", i+1)
        s=i2
        if i < 0 or i2 < 0:
            done=True
            break
        else:
            fname_slice = fname[i+1:i2]
            name, value = fname_slice.split("=", 1)
            ret[name]=value
    return ret

def calculate_helpers(df: pd.DataFrame):
    n = max(df["n-sources"].values)
    df_helpers = (df.loc[:, "x1":"x{}".format(n):2]-df.loc[:, "x1est":"x{}est".format(n):2].values).rename(columns={"x{}".format(i):"x{}matched".format(i) for i in range(8)})
    df_helpers = df_helpers.apply(is_matched, axis=1, raw=False)
    df_helpers["total-matched"] = df_helpers.sum(axis=1)
    df_helpers["percent-matched"] = df_helpers["total-matched"] / df["n-sources"].values
    return df_helpers

def matlab2pandas(dirname=EVALUATIONS, filename=NAME_DATA_FILES, save_to=None, summary=True):
    dfs = []
    if type(dirname)!=list:
        dirnames = [dirname, ]
    else: dirnames = dirname
    max_n_sources = 0
    for dirname in dirnames:
        files = glob.glob(path.join(PATH_ROOT,dirname,filename))
        dfs = []

        # read data
        for f in files:
            # look at filename
            fname = f.split(sep="/")[-1]
            params = parse_parameters(fname)
            n_sources = int(params["s"])
            if n_sources > max_n_sources:
                max_n_sources = n_sources
            # prepare DataFrame
            df = pd.DataFrame(list(csv.reader(open(f, 'r'), delimiter='\t')), dtype=float)
            df.drop(df.columns[[n_sources*4+n_sources]], axis=1, inplace=True) # drops empty column
            df.columns = get_col_names(n_sources)
            df.index = ["t{}".format(i+1) for i in range(len(df))]
            for key, value in params.items():
                df[key] = np.float(value)
            df["description"] = dirname
            dfs.append(df)
        df = pd.concat(dfs)

        # prep data for analysis
        df.rename(columns={'s':'n-sources', 'refl-ord':'reflect-order'}, inplace=True)
        df['SNR'] = df['SNR'].apply(int)
        df['em'] = df['em'].apply(int)
        df['n-sources'] = df['n-sources'].apply(int)
        df["T60"].apply(round, 2)
        df["err-mean"]      = df.loc[:, "err1":_get_err_col_name(n_sources)[-1]].mean(axis=1)
        df["err-total"]     = df.loc[:, "err1":_get_err_col_name(n_sources)[-1]].sum(axis=1)
        df_helpers = calculate_helpers(df)
        df = pd.concat([df,df_helpers], axis=1)
        if summary:
            print_summary(df)

        if save_to:
            df.to_pickle(save_to+".pkl")
        dfs.append(df)
    return pd.concat(dfs, ignore_index=True)
