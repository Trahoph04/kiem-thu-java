"""In kết quả bộ ca chung TC01–TC16 của JUnit, TestNG và Spock thành một bảng, đọc từ báo cáo XML của Surefire.

  python3 demo/bang-ket-qua.py bang <thư mục XML junit> <testng> <spock> [--luu kq.json]
  python3 demo/bang-ket-qua.py tong-hop <kq-ma-dung.json> <kq-ma-loi.json> <so-lieu.txt> [junit-mac-dinh.log]
"""
import json
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

CONG_CU = [("junit", "JUnit"), ("testng", "TestNG"), ("spock", "Spock")]
MO_TA = {
    "TC01": "giá null → ngoại lệ", "TC02": "giá -1 → ngoại lệ", "TC03": "giá 0 → ngoại lệ",
    "TC04": "1 → 1", "TC05": "300.000 → 300.000", "TC06": "499.999 → 499.999",
    "TC07": "500.000 → 475.000", "TC08": "750.000 → 712.500", "TC09": "999.999 → 949.999",
    "TC10": "1.000.000 → 900.000", "TC11": "2.000.000 → 1.800.000", "TC12": "500.010 → 475.010 (làm tròn)",
    "TC13": "1.000.005 → 900.005 (làm tròn)", "TC14": "lưu ORD-001 với 900.000",
    "TC15": "mã đơn {} → từ chối, không lưu", "TC16": "giá 0 → từ chối, không lưu",
}
HANG = [(f"TC{i:02d}", None) for i in range(1, 15)] + [("TC15", v) for v in ("null", '""', '"   "')] + [("TC16", None)]
# TestNG không có mã ca trong tên của 3 phương thức này
TESTNG_PHUONG_THUC = {"savesOrderWithFinalPrice": "TC14", "rejectsBlankOrderIdWithoutSaving": "TC15",
                      "rejectsInvalidSubtotalWithoutSaving": "TC16"}
XANH, DO, MO, DAM, HET = "\033[32m", "\033[31m", "\033[2m", "\033[1m", "\033[0m"


def bien_the(ten):
    if "null" in ten:
        return "null"
    return '"   "' if re.search(r'[\["]   [\]"]', ten) else '""'


def doc(thu_muc):
    """→ ({(mã, biến thể): {"dat", "ten", "loi"}}, [ca ngoài bộ chung], số nút Surefire đếm)"""
    ket_qua, ngoai, so_nut = {}, [], 0
    for f in sorted(pathlib.Path(thu_muc).glob("TEST-*.xml")):
        for tc in ET.parse(f).getroot().iter("testcase"):
            so_nut += 1
            ten = tc.get("name")
            if "#" in ten:  # nút cha của bảng where: trong Spock, không phải một lần chạy
                continue
            ma_ca = re.findall(r"TC\d\d|HN\d\d", ten)
            ma = ma_ca[-1] if ma_ca else TESTNG_PHUONG_THUC.get(ten.split("[")[0])
            loi = tc.find("failure")
            if loi is None:
                loi = tc.find("error")
            muc = {"dat": loi is None, "ten": ten,
                   "loi": (loi.get("message") or loi.get("type") or "") if loi is not None else ""}
            if ma and "TC01" <= ma <= "TC16" and not ma.startswith("HN"):
                ket_qua[(ma, bien_the(ten) if ma == "TC15" else None)] = muc
            else:
                ngoai.append((ma or ten, muc))
    return ket_qua, ngoai, so_nut


def bang(dirs, luu=None):
    du_lieu = {k: doc(d) for (k, _), d in zip(CONG_CU, dirs)}
    print(f"\n{DAM}{'Ca':<5} {'Nội dung':<34} {'JUnit':^8} {'TestNG':^8} {'Spock':^8}{HET}")
    print("─" * 67)
    tong = {k: [0, 0] for k, _ in CONG_CU}
    ca_do = {k: [] for k, _ in CONG_CU}
    for ma, bt in HANG:
        mo_ta = MO_TA[ma].format(bt) if bt else MO_TA[ma]
        o = []
        for k, _ in CONG_CU:
            muc = du_lieu[k][0].get((ma, bt))
            if muc is None:
                o.append(f"{MO}{'–':^8}{HET}")
                continue
            tong[k][1] += 1
            if muc["dat"]:
                tong[k][0] += 1
                o.append(f"{XANH}{'✔':^8}{HET}")
            else:
                ca_do[k].append(ma if not bt else f"{ma} {bt}")
                o.append(f"{DO}{DAM}{'✘':^8}{HET}")
        print(f"{ma:<5} {mo_ta:<34} {' '.join(o)}")
    print("─" * 67)
    print(f"{DAM}{'Đạt':<40}" + " ".join(f"{f'{d}/{n}':^8}" for d, n in tong.values()) + HET)
    _, ngoai_j, _ = du_lieu["junit"]
    if ngoai_j:
        dat = sum(m["dat"] for _, m in ngoai_j)
        print(f"{MO}JUnit còn {len(ngoai_j)} ca ngoài bộ chung (HN01, TC17–TC28 của các kịch bản bảo trì): {dat}/{len(ngoai_j)} đạt{HET}")
    so_nut_spock = du_lieu["spock"][2]
    if so_nut_spock != tong["spock"][1]:
        print(f"{MO}Surefire đếm Spock là {so_nut_spock} vì tính cả {so_nut_spock - tong['spock'][1]} nút cha của bảng where:{HET}")

    ca_dau = next(((ma, bt) for ma, bt in HANG
                   if any(du_lieu[k][0].get((ma, bt), {"dat": True})["dat"] is False for k, _ in CONG_CU)), None)
    if ca_dau:
        ma, bt = ca_dau
        print(f"\n{DAM}Cách mỗi công cụ báo lỗi ở ca {ma}:{HET}")
        for k, ten_cc in CONG_CU:
            muc = du_lieu[k][0].get(ca_dau)
            if not muc or muc["dat"]:
                continue
            print(f"\n  {DAM}{ten_cc}{HET} {MO}– tên ca trong báo cáo:{HET} {muc['ten']}")
            dong = [d.replace("\t", "  ") for d in muc["loi"].splitlines() if d.strip()][:7]
            for d in dong:
                print(f"    {DO}{d}{HET}")
    if luu:
        pathlib.Path(luu).write_text(json.dumps({
            "tong": tong, "ca_do": ca_do, "so_nut_spock": so_nut_spock,
        }, ensure_ascii=False))


def so_lieu(tep):
    """Đọc demo-output/01-so-lieu.txt do do-so-lieu.sh ghi."""
    kq = {k: {} for k in ("junit-mockito", "testng", "spock")}
    muc = None
    for dong in pathlib.Path(tep).read_text(encoding="utf-8").splitlines():
        if dong.startswith("== "):
            muc = dong
            continue
        m = re.match(r"(junit-mockito|testng|spock)( lần \d+)?:\s*(.*)", dong)
        if not m or not muc:
            continue
        k, gt = m.group(1), m.group(3)
        if "Dòng mã test" in muc:
            kq[k]["loc"] = int(gt)
        elif "cấu hình" in muc:
            kq[k]["cau_hinh"] = int(gt.split()[0])
        elif "classpath" in muc:
            kq[k]["thu_vien"] = gt
        elif "Thời gian" in muc:
            kq[k].setdefault("tg", []).append(float(gt.split("|")[0]))
    for v in kq.values():
        if v.get("tg"):
            v["tg"] = sorted(v["tg"])[len(v["tg"]) // 2]
    return kq


def tong_hop(dung, loi, tep_so_lieu, junit_mac_dinh=None):
    doc_json = lambda p: json.loads(pathlib.Path(p).read_text()) if p and pathlib.Path(p).exists() else None
    d, l = doc_json(dung), doc_json(loi)
    s = so_lieu(tep_so_lieu) if tep_so_lieu and pathlib.Path(tep_so_lieu).exists() else {}
    khoa = {"junit": "junit-mockito", "testng": "testng", "spock": "spock"}
    junit_chi_so = None
    if junit_mac_dinh and pathlib.Path(junit_mac_dinh).exists():
        junit_chi_so = "TC07" not in pathlib.Path(junit_mac_dinh).read_text(encoding="utf-8")

    def o(k, gt):
        return f"{gt:^15}"

    hang = []
    if d:
        hang.append(("Mã đúng: số lần chạy đạt", {k: f"{d['tong'][k][0]}/{d['tong'][k][1]}" for k, _ in CONG_CU}))
    if l:
        hang.append(("Gây lỗi: số ca phát hiện", {k: f"{len(l['ca_do'][k])} ca ✘" for k, _ in CONG_CU}))
        hang.append(("Báo lỗi có chỉ ra mã ca", {
            "junit": "Không ([4])" if junit_chi_so else "Có (đã cấu hình)", "testng": "Có (tham số)", "spock": "Có + giá trị"}))
    if s:
        hang.append(("Dòng mã test", {k: str(s[khoa[k]].get("loc", "–")) for k, _ in CONG_CU}))
        hang.append(("Dòng cấu hình trong pom.xml", {k: str(s[khoa[k]].get("cau_hinh", "–")) for k, _ in CONG_CU}))
        hang.append(("Plugin build phải thêm", {"junit": "0", "testng": "0", "spock": "1"}))
        hang.append(("Thời gian mvn clean test", {
            k: (f"{s[khoa[k]]['tg']:.2f} s".replace(".", ",") if s[khoa[k]].get("tg") else "–") for k, _ in CONG_CU}))
    print(f"\n{DAM}{'Kết quả vừa chạy trong video':<32}{'JUnit':^15}{'TestNG':^15}{'Spock':^15}{HET}")
    print("─" * 77)
    for ten, gt in hang:
        print(f"{ten:<32}" + "".join(o(k, gt[k]) for k, _ in CONG_CU))
    if l:
        chung = sorted(set.intersection(*(set(v) for v in l["ca_do"].values())))
        print(f"{MO}Cả ba công cụ cùng báo đỏ ở: {', '.join(chung) or '–'}{HET}")

    tieu_chi = [("Phổ biến, cộng đồng", 20, (5, 3, 3)), ("Tích hợp hệ sinh thái Java", 20, (5, 4, 3)),
                ("Chi phí học, duy trì (đội Java)", 15, (5, 4, 2)), ("Chẩn đoán lỗi khi hồi quy", 15, (3, 4, 5)),
                ("Dễ đọc, ngắn gọn", 10, (4, 3, 5)), ("Tính năng nâng cao", 10, (4, 5, 4)),
                ("Độ chặt của kết quả", 10, (5, 4, 3))]
    print(f"\n{DAM}{'Chấm điểm (thang 1–5) × trọng số':<32}{'Trọng số':^10}{'JUnit':^10}{'TestNG':^10}{'Spock':^10}{HET}")
    print("─" * 72)
    tong = [0, 0, 0]
    for ten, w, diem in tieu_chi:
        print(f"{ten:<32}{w:^10}" + "".join(f"{x:^10}" for x in diem))
        tong = [t + w * x for t, x in zip(tong, diem)]
    print("─" * 72)
    tong = [t // 5 for t in tong]
    print(f"{DAM}{'Tổng điểm /100':<32}{'':^10}" + "".join(f"{t:^10}" for t in tong) + HET)
    ten_cc = [t for _, t in CONG_CU]
    xep = sorted(zip(tong, ten_cc), reverse=True)
    print(f"\n{DAM}{XANH}→ Kết luận: chọn {xep[0][1]} (+ Mockito): {xep[0][0]} điểm, "
          f"{xep[1][1]} {xep[1][0]}, {xep[2][1]} {xep[2][0]}.{HET}")


if __name__ == "__main__":
    lenh, *thamso = sys.argv[1:]
    if lenh == "bang":
        luu = thamso[thamso.index("--luu") + 1] if "--luu" in thamso else None
        bang([a for a in thamso if a != "--luu" and a != luu][:3], luu)
    elif lenh == "tong-hop":
        tong_hop(*(thamso + [None] * (4 - len(thamso)))[:4])
