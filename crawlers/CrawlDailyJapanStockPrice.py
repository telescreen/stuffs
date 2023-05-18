
# conda install pandas
# conda install pandas-datareader
# pip install yfinance --upgrade --no-cache-dir
# conda install xlrd
import urllib
import csv
import pandas as pd
import datetime
# import fix_yahoo_finance as yf
import yfinance as yf

# float型への変換チェック
def isfloat(obj: any):
    if not obj.isdecimal():
        try:
            float(obj)
            return True
        except ValueError:
            return False
    else:
        return True

def fetch_price(symbolsDf, start_date, end_date):
     # 取得した銘柄コード一覧から、株価情報を取得する。
    for codeIdx in range(len(symbolsDf)):
        if codeIdx >= 0:
            # 対象の銘柄コードを設定。
            symbolCode = str(symbolsDf.loc[codeIdx, "コード"])

            # システム日付を取得
            sysDateTime: str = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            # 進捗
            strBuf: str = ""
            strBuf = strBuf + "   (" + str(codeIdx + 1) + "/" + str(len(symbolsDf)) + ") " + str(
                '{:.2f}'.format(((codeIdx + 1) * 100 / len(symbolsDf)))) + '%\t'
            strBuf = strBuf + "\t銘柄コード：" + str(symbolCode) + "\t日付：" + sysDateTime
            print(strBuf)

            # 日別株価を取得
            try:
                df = yf.download(symbolCode+'.T', start=start_date, end=end_date)
            except ValueError as err:
                continue
            except Exception as err:
                print("Error:" + str(err))
                break

            for i in range(len(df)):
                try:
                    # 初期化
                    if i == 0:
                        fltADJ_CLOSE_PRICE = 0

                    # 値を設定
                    strBRAND_CD = symbolCode
                    # 始値
                    if isfloat(str(df.loc[df.index[i], "Open"])):
                        fltOPEN_PRICE = round(float(df.loc[df.index[i], "Open"]), 1)
                    else:
                        fltOPEN_PRICE = 0.00
                    # 高値
                    if isfloat(str(df.loc[df.index[i], "High"])):
                        fltHIGH_PRICE = float(df.loc[df.index[i], "High"])
                    else:
                        fltHIGH_PRICE = 0.00
                    # 安値
                    if isfloat(str(df.loc[df.index[i], "Low"])):
                        fltLOW_PRICE = float(df.loc[df.index[i], "Low"])
                    else:
                        fltLOW_PRICE = 0.00
                    # 終値
                    if isfloat(str(df.loc[df.index[i], "Close"])):
                        fltCLOSE_PRICE = float(df.loc[df.index[i], "Close"])
                    else:
                        fltCLOSE_PRICE = 0.00
                    # 修正後終値
                    if isfloat(str(df.loc[df.index[i], "Adj Close"])):
                        fltADJ_CLOSE_PRICE = float(df.loc[df.index[i], "Adj Close"])
                    else:
                        fltADJ_CLOSE_PRICE = 0.00
                    # 売買高
                    if str(df.loc[df.index[i], "Volume"]).isnumeric():
                        fltVOLUME_SU = float(df.loc[df.index[i], "Volume"])
                    else:
                        fltVOLUME_SU = 0.00

                    # 対象日付をセット
                    dateTARGET_DT = datetime.datetime.strptime(str(df.index[i]), '%Y-%m-%d 00:00:00')

                    yield [strBRAND_CD, dateTARGET_DT.strftime("%Y/%m/%d"), fltOPEN_PRICE, fltHIGH_PRICE,
                           fltLOW_PRICE, fltCLOSE_PRICE, fltADJ_CLOSE_PRICE, fltVOLUME_SU]

                except KeyError as err:
                    print("KeyError:" + str(err))
                    pass
                except ValueError as err:
                    print("ValueError:" + str(err))
                    pass
                except Exception as err:
                    print("Error:" + str(err))
                    break

if __name__ == '__main__':
    # try:
    print("/*--START-----------------------------------------------------*/")
    print("/*--日本株の株価取得プログラム*/")

    start = datetime.datetime.today()  # 取得したい開始期間
    end = datetime.datetime.today()  # 取得したい終了期間(システム日付)

    # 全銘柄情報取得
    # 銘柄データ(data_j.xls)を一覧表から取得
    inputDf: pd.core.frame.DataFrame
    # 日本取引所グループから、東証上場銘柄一覧をダウンロード
    url = "https://www.jpx.co.jp/markets/statistics-equities/misc/tvdivq0000001vg2-att/data_j.xls"
    save_name = "data_j.xls"
    urllib.request.urlretrieve(url, save_name)

    symbolsDf: pd.core.frame.DataFrame
    symbolsDf = pd.read_excel('data_j.xls')

    filename = "daily_price{}.csv".format(start.strftime("%m%d"))

    with open(filename, 'w') as f:
        writer = csv.writer(f, quoting=csv.QUOTE_ALL)
        writer.writerow(["銘柄","日付", "始値","高値", "安値", "終値", "終値調整", "売買高", "前日増減額", "前日増減率"])
        #for row in fetch_price(symbolsDf, start, end):
        for row in fetch_price(symbolsDf, start, end):
            writer.writerow(row)

    print("/*--FINISH-----------------------------------------------------*/")
