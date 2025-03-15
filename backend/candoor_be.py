from flask import Flask, request

app = Flask(__name__)

@app.route('/connect', methods=['POST'])
def connect():
    print("📡 Nhận yêu cầu kết nối từ Flutter!")
    return {"message": "Backend nhận kết nối thành công!"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
