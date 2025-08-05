#ifndef __SUPER_AI_H__
#define __SUPER_AI_H__

#include "pastor_ai.hpp"

#define INPUT_SIZE 768
#define HALF_INPUT_SIZE INPUT_SIZE / 2

class VioletAI : public PastorAI {
private:
	NNUE nnue;

public:
	VioletAI();

public:
	int calculateIndex(int square, int pieceType, int side);
	void quies(godot::Ref<State> _state, int _group = 0);
};

class Layer {
public:
	virtual std::vector<std::vector<float>> forward(const std::vector<std::vector<float>> &input) = 0;
	virtual std::vector<std::vector<float>> backward(const std::vector<std::vector<float>> &grad_output) = 0;
	virtual ~Layer() = default;
};

class LinearLayer : public Layer {
public:
	int in_features;
	int out_features;
	std::vector<std::vector<float>> weight;
	std::vector<float> bias;
	std::vector<std::vector<float>> grad_weight; // 权重梯度
	std::vector<float> grad_bias; // 偏置梯度
	std::vector<std::vector<float>> input_cache; // 缓存输入值（反向传播用）

public:
	LinearLayer(int in, int out);
	virtual std::vector<std::vector<float>> forward(const std::vector<std::vector<float>> &input) override;
	virtual std::vector<std::vector<float>> backward(const std::vector<std::vector<float>> &grad) override;
	void sgd_update(float lr);
};

class ActivationLayer : public Layer {
public:
	virtual std::vector<std::vector<float>> forward(const std::vector<std::vector<float>> &input) = 0;
	virtual std::vector<std::vector<float>> backward(const std::vector<std::vector<float>> &grad_output) = 0;
};

class ReluLayer : public ActivationLayer {
private:
	std::vector<std::vector<float>> input_cache;

public:
	std::vector<std::vector<float>> forward(const std::vector<std::vector<float>> &input) override;
	std::vector<std::vector<float>> backward(const std::vector<std::vector<float>> &grad_output) override;
};

class SigmoidLayer : public ActivationLayer {
private:
	std::vector<std::vector<float>> output_cache;

public:
	std::vector<std::vector<float>> forward(const std::vector<std::vector<float>> &input) override;
	std::vector<std::vector<float>> backward(const std::vector<std::vector<float>> &grad_output) override;
};

class Concat {
public:
	std::vector<std::vector<float>> forward(const std::vector<std::vector<float>> &input1, const std::vector<std::vector<float>> &input2);

	// 反向传播：将梯度拆分到两个输入上
	std::pair<std::vector<std::vector<float>>, std::vector<std::vector<float>>> backward(const std::vector<std::vector<float>> &grad_output, int input1_size, int input2_size);
};

class Loss {
public:
	virtual float forward(const std::vector<std::vector<float>> &pred, const std::vector<std::vector<float>> &target) = 0;
	virtual std::vector<std::vector<float>> backward() = 0;
};

class MSELoss : public Loss {
public:
	std::vector<std::vector<float>> y_pred, y_true;

public:
	float forward(const std::vector<std::vector<float>> &pred, const std::vector<std::vector<float>> &target) override;
	std::vector<std::vector<float>> backward() override;
};

class Accumulate : public LinearLayer {
public:
	float acc[INPUT_SIZE];

public:
	Accumulate();

public:
	std::vector<std::vector<float>> forward(const std::vector<std::vector<float>> &input) override;
	// std::vector<std::vector<float>> backward(const std::vector<std::vector<float>> &grad_output) override;
};

class NNUE {
private:
	Accumulate acc;
	LinearLayer layer1 = LinearLayer(8, 8);
	ReluLayer relu1;
	LinearLayer layer2 = LinearLayer(8, 1);
	SigmoidLayer sigmoid;

public:
	void train(const godot::Array &x, const godot::Array &y, float lr, int epoch);
	float predict(const godot::Array &input);
};

#endif // __SUPER_AI_H__