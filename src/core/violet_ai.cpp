#include "violet_ai.hpp"
#include <cmath>
#include <random>

VioletAI::VioletAI() :
		PastorAI() {
}

int VioletAI::calculateIndex(int square, int pieceType, int side) {
	return side * 64 * 6 + pieceType * 64 + square;
}

void VioletAI::quies(godot::Ref<State> _state, int _group) {
	PastorAI::quies(_state->duplicate(), -60000, 60000, _group);
}

LinearLayer::LinearLayer(int in_f, int out_f) :
		in_features(in_f), out_features(out_f) {
	std::default_random_engine gen;
	std::normal_distribution<float> dist(0.0f, 0.01f);

	weight.resize(out_f, std::vector<float>(in_f));
	grad_weight.resize(out_f, std::vector<float>(in_f, 0.0f));
	bias.resize(out_f, 0.0f);
	grad_bias.resize(out_f, 0.0f);

	for (int i = 0; i < out_f; ++i)
		for (int j = 0; j < in_f; ++j)
			weight[i][j] = dist(gen);
}

std::vector<std::vector<float>> LinearLayer::forward(const std::vector<std::vector<float>> &input) {
	input_cache = input;
	int batch = input.size();
	std::vector<std::vector<float>> output(batch, std::vector<float>(out_features, 0.0f));

	for (int b = 0; b < batch; ++b)
		for (int i = 0; i < out_features; ++i) {
			float sum = bias[i];
			for (int j = 0; j < in_features; ++j)
				sum += input[b][j] * weight[i][j];
			output[b][i] = sum;
		}

	return output;
}

std::vector<std::vector<float>> LinearLayer::backward(const std::vector<std::vector<float>> &grad_output) {
	int batch = grad_output.size();

	for (int i = 0; i < out_features; ++i) {
		grad_bias[i] = 0.0f;
		for (int j = 0; j < in_features; ++j)
			grad_weight[i][j] = 0.0f;
	}

	for (int b = 0; b < batch; ++b)
		for (int i = 0; i < out_features; ++i) {
			grad_bias[i] += grad_output[b][i];
			for (int j = 0; j < in_features; ++j)
				grad_weight[i][j] += grad_output[b][i] * input_cache[b][j];
		}

	std::vector<std::vector<float>> grad_input(batch, std::vector<float>(in_features, 0.0f));
	for (int b = 0; b < batch; ++b)
		for (int j = 0; j < in_features; ++j)
			for (int i = 0; i < out_features; ++i)
				grad_input[b][j] += grad_output[b][i] * weight[i][j];

	return grad_input;
}

void LinearLayer::sgd_update(float lr) {
	for (int i = 0; i < out_features; ++i) {
		bias[i] -= lr * grad_bias[i];
		for (int j = 0; j < in_features; ++j)
			weight[i][j] -= lr * grad_weight[i][j];
	}
}

void NNUE::train(const godot::Array &x, const godot::Array &y, float lr, int epoch) {
	std::vector<std::vector<float>> input(x.size(), std::vector<float>());
	for (int i = 0; i < x.size(); ++i) {
		godot::Array arr1 = static_cast<godot::Array>(x.get(i));
		for (int j = 0; j < arr1.size(); j++) {
			if (arr1.get(j).operator bool()) {
				input[i].push_back(j);
			}
		}
	}

	std::vector<std::vector<float>> targets(y.size(), std::vector<float>(1));
	for (size_t i = 0; i < y.size(); ++i) {
		targets[i][0] = y[i];
	}

	for (int e = 0; e < epoch; ++e) {
		float total_loss = 0.0f;

		std::vector<std::vector<float>> acc_out = acc.forward(input);
		std::vector<std::vector<float>> l1_out = layer1.forward(acc_out);
		std::vector<std::vector<float>> l1_relu = relu1.forward(l1_out);
		std::vector<std::vector<float>> l2_out = layer2.forward(l1_relu);
		std::vector<std::vector<float>> predictions = sigmoid.forward(l2_out);

		MSELoss loss_fn;
		float loss = loss_fn.forward(predictions, targets);
		total_loss += loss;

		std::vector<std::vector<float>> grad_loss = loss_fn.backward();
		std::vector<std::vector<float>> grad_sigmoid = sigmoid.backward(grad_loss);
		std::vector<std::vector<float>> grad_l2 = layer2.backward(grad_sigmoid);
		std::vector<std::vector<float>> grad_relu = relu1.backward(grad_l2);
		std::vector<std::vector<float>> grad_l1 = layer1.backward(grad_relu);
		std::vector<std::vector<float>> grad_acc = acc.backward(grad_l1);

		acc.sgd_update(lr);
		layer1.sgd_update(lr);
		layer2.sgd_update(lr);

		// 打印训练进度
		if (e % 10 == 0 || e == epoch - 1) {
			std::cout << "Epoch " << e << "/" << epoch << " - Loss: " << (total_loss / x.size()) << std::endl;
		}
	}
}

std::vector<std::vector<float>> ReluLayer::forward(const std::vector<std::vector<float>> &input) {
	input_cache = input;
	std::vector<std::vector<float>> output = input;

	for (auto &row : output)
		for (auto &val : row)
			val = std::max(0.0f, val);

	return output;
}

std::vector<std::vector<float>> ReluLayer::backward(const std::vector<std::vector<float>> &grad_output) {
	std::vector<std::vector<float>> grad_input = grad_output;

	for (int i = 0; i < input_cache.size(); ++i)
		for (int j = 0; j < input_cache[0].size(); ++j)
			grad_input[i][j] *= (input_cache[i][j] > 0.0f) ? 1.0f : 0.0f;

	return grad_input;
}

float MSELoss::forward(const std::vector<std::vector<float>> &pred, const std::vector<std::vector<float>> &target) {
	y_pred = pred;
	y_true = target;
	float loss = 0.0f;
	int n = pred.size(), m = pred[0].size();

	for (int i = 0; i < n; ++i)
		for (int j = 0; j < m; ++j)
			loss += (pred[i][j] - target[i][j]) * (pred[i][j] - target[i][j]);

	return loss / (n * m);
}

std::vector<std::vector<float>> MSELoss::backward() {
	int n = y_pred.size(), m = y_pred[0].size();
	std::vector<std::vector<float>> grad(n, std::vector<float>(m));

	for (int i = 0; i < n; ++i)
		for (int j = 0; j < m; ++j)
			grad[i][j] = 2.0f * (y_pred[i][j] - y_true[i][j]) / (n * m);

	return grad;
}

Accumulate::Accumulate() :
		LinearLayer(768, 8) {
}

std::vector<std::vector<float>> Accumulate::forward(const std::vector<std::vector<float>> &input) {
	input_cache = input;
	int batch = input.size();
	std::vector<std::vector<float>> output(batch, std::vector<float>(out_features, 0.0f));

	for (int b = 0; b < batch; b++) {
		for (int i = 0; i < out_features; i++) {
			float sum = bias[i];
			for (int active : input[b]) {
				sum += weight[active][i];
			}
			output[b][i] = sum;
		}
	}

	return output;
}

std::vector<std::vector<float>> SigmoidLayer::forward(const std::vector<std::vector<float>> &input) {
	int batch = input.size();
	int dim = input[0].size();
	output_cache.resize(batch, std::vector<float>(dim));

	for (int i = 0; i < batch; ++i) {
		for (int j = 0; j < dim; ++j) {
			float val = 1.0f / (1.0f + std::exp(-input[i][j]));
			output_cache[i][j] = val;
		}
	}

	return output_cache;
}

std::vector<std::vector<float>> SigmoidLayer::backward(const std::vector<std::vector<float>> &grad_output) {
	int batch = grad_output.size();
	int dim = grad_output[0].size();
	std::vector<std::vector<float>> grad_input(batch, std::vector<float>(dim));

	for (int i = 0; i < batch; ++i) {
		for (int j = 0; j < dim; ++j) {
			float sig = output_cache[i][j];
			grad_input[i][j] = grad_output[i][j] * sig * (1.0f - sig);
		}
	}

	return grad_input;
}

float NNUE::predict(const godot::Array &binary_input) {
	std::vector<float> input;
	for (int i = 0; i < binary_input.size(); ++i) {
		input.push_back(binary_input[i]);
	}
	std::vector<std::vector<float>> input_vec = { input };
	std::vector<std::vector<float>> acc_out = acc.forward(input_vec);
	std::vector<std::vector<float>> l1_out = layer1.forward(acc_out);
	std::vector<std::vector<float>> l1_relu = relu1.forward(l1_out);
	std::vector<std::vector<float>> l2_out = layer2.forward(l1_relu);
	std::vector<std::vector<float>> output = sigmoid.forward(l2_out);

	return output[0][0];
}